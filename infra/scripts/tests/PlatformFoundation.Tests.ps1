BeforeAll {
    $script:root = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
    $script:loader = Join-Path $script:root 'infra\scripts\Get-PlatformConfiguration.ps1'
    if (Test-Path $script:loader) { . $script:loader }
    function New-TestPlatformConfig {
        @{
            tenantId = '11111111-1111-1111-1111-111111111111'
            environments = @{
                dev = @{ url = 'https://unit-dev.crm.dynamics.com'; environmentId = '22222222-2222-2222-2222-222222222222'; organizationId = '33333333-3333-3333-3333-333333333333'; clientId = '' }
                test = @{ url = 'https://unit-test.crm.dynamics.com'; environmentId = '44444444-4444-4444-4444-444444444444'; organizationId = '55555555-5555-5555-5555-555555555555'; clientId = '' }
                prod = @{ url = 'https://unit-prod.crm.dynamics.com'; environmentId = '66666666-6666-6666-6666-666666666666'; organizationId = '77777777-7777-7777-7777-777777777777'; clientId = '' }
            }
        }
    }
}

Describe 'Private platform configuration' {
    BeforeEach {
        $script:config = New-TestPlatformConfig
        $script:path = Join-Path $TestDrive 'platform.json'
    }
    It 'loads all three verified targets without requiring CI identities for human discovery' {
        $script:config | ConvertTo-Json -Depth 10 | Set-Content $script:path
        $actual = Get-PlatformConfiguration -Path $script:path
        $actual.environments.Keys | Sort-Object | Should -Be @('dev', 'prod', 'test')
    }
    It 'rejects a missing PROD slot' {
        $script:config.environments.Remove('prod')
        $script:config | ConvertTo-Json -Depth 10 | Set-Content $script:path
        { Get-PlatformConfiguration -Path $script:path } | Should -Throw '*dev, test and prod*'
    }
    It 'rejects placeholder tenant identities' {
        $script:config.tenantId = '00000000-0000-0000-0000-000000000000'
        $script:config | ConvertTo-Json -Depth 10 | Set-Content $script:path
        { Get-PlatformConfiguration -Path $script:path } | Should -Throw '*tenantId*'
    }
    It 'rejects non-Dataverse or insecure endpoints' -ForEach @(
        @{ Url = 'http://unit-dev.crm.dynamics.com' }
        @{ Url = 'https://example.com' }
        @{ Url = 'https://unit-dev.crm.dynamics.com/other' }
        @{ Url = 'https://user@unit-dev.crm.dynamics.com' }
        @{ Url = 'https://unit-dev.crm.dynamics.com?redirect=other' }
    ) {
        $script:config.environments.dev.url = $Url
        $script:config | ConvertTo-Json -Depth 10 | Set-Content $script:path
        { Get-PlatformConfiguration -Path $script:path } | Should -Throw '*endpoint*'
    }
    It 'rejects duplicate environment targets' {
        $script:config.environments.prod.url = $script:config.environments.dev.url
        $script:config | ConvertTo-Json -Depth 10 | Set-Content $script:path
        { Get-PlatformConfiguration -Path $script:path } | Should -Throw '*distinct*'
    }
    It 'rejects duplicate organization identities' {
        $script:config.environments.prod.organizationId = $script:config.environments.dev.organizationId
        $script:config | ConvertTo-Json -Depth 10 | Set-Content $script:path
        { Get-PlatformConfiguration -Path $script:path } | Should -Throw '*distinct*'
    }
    It 'rejects reusing a CI identity across environments' {
        $script:config.environments.dev.clientId = '88888888-8888-8888-8888-888888888888'
        $script:config.environments.prod.clientId = $script:config.environments.dev.clientId
        $script:config | ConvertTo-Json -Depth 10 | Set-Content $script:path
        { Get-PlatformConfiguration -Path $script:path } | Should -Throw '*distinct*'
    }
    It 'rejects cross-tenant access before a mutation' {
        { Assert-PlatformIdentity -Configuration $script:config -Slot dev `
            -TokenTenantId '99999999-9999-9999-9999-999999999999' `
            -OrganizationId $script:config.environments.dev.organizationId } | Should -Throw '*tenant*'
    }
    It 'rejects a different organization behind the configured URL' {
        { Assert-PlatformIdentity -Configuration $script:config -Slot dev `
            -TokenTenantId $script:config.tenantId `
            -OrganizationId $script:config.environments.test.organizationId } | Should -Throw '*organization*'
    }
    It 'accepts exactly the configured tenant and organization' {
        { Assert-PlatformIdentity -Configuration $script:config -Slot prod `
            -TokenTenantId $script:config.tenantId `
            -OrganizationId $script:config.environments.prod.organizationId } | Should -Not -Throw
    }
    It 'preserves an explicit bootstrap slot and private configuration path' {
        $script:config.environments.dev.clientId = '88888888-8888-8888-8888-888888888888'
        $script:config | ConvertTo-Json -Depth 10 | Set-Content $script:path
        $bootstrap = Join-Path $script:root 'infra\scripts\add-ci-app-users.ps1'
        { & $bootstrap -ConfigurationPath $script:path -Slot dev -WhatIf } | Should -Not -Throw
    }
    It 'does not silently replace a missing explicit configuration with the default' {
        $bootstrap = Join-Path $script:root 'infra\scripts\add-ci-app-users.ps1'
        { & $bootstrap -ConfigurationPath (Join-Path $TestDrive 'missing.json') -Slot dev -WhatIf } |
            Should -Throw
    }
}

Describe 'Three-slot infrastructure and deployment contract' {
    It 'preserves the verified regional URL rather than inventing a CRM suffix' {
        $source = Get-Content (Join-Path $script:root 'infra\terraform\modules\powerplatform\outputs.tf') -Raw
        $source | Should -Match 'env\.url'
        $source | Should -Not -Match 'https://.*\.crm\.dynamics\.com'
    }
    It 'resolves a relative private configuration path before changing the import directory' {
        $source = Get-Content (Join-Path $script:root 'infra\scripts\bootstrap-import.ps1') -Raw
        $source | Should -Match '(?s)\$ConfigurationPath\s*=\s*\(Resolve-Path.*?Push-Location'
    }
    It 'declares PROD and protects existing environments from destruction' {
        $root = Get-Content (Join-Path $script:root 'infra\terraform\main.tf') -Raw
        $root | Should -Match '(?s)prod\s*=\s*\{'
        Get-Content (Join-Path $script:root 'infra\terraform\modules\powerplatform\main.tf') -Raw |
            Should -Match 'prevent_destroy\s*=\s*true'
    }
    It 'does not manage shared tenant settings without explicit opt-in' {
        Get-Content (Join-Path $script:root 'infra\terraform\modules\powerplatform\main.tf') -Raw |
            Should -Match 'count\s*=\s*var.manage_tenant_settings\s*\?\s*1\s*:\s*0'
        Get-Content (Join-Path $script:root 'infra\terraform\variables.tf') -Raw |
            Should -Match '(?s)variable "manage_tenant_settings".*?default\s*=\s*false'
    }
    It 'references existing environments without modifying their access policy by default' {
        Get-Content (Join-Path $script:root 'infra\terraform\variables.tf') -Raw |
            Should -Match '(?s)variable "manage_environments".*?default\s*=\s*false'
        Get-Content (Join-Path $script:root 'infra\terraform\modules\powerplatform\main.tf') -Raw |
            Should -Match 'var.manage_environments\s*\?\s*var.environments\s*:\s*\{\}'
    }
    It 'bootstraps application users by configured IDs rather than old hard-coded targets' {
        $source = Get-Content (Join-Path $script:root 'infra\scripts\add-ci-app-users.ps1') -Raw
        $source | Should -Match 'SupportsShouldProcess'
        $source | Should -Match 'Get-PlatformConfiguration'
        $source | Should -Not -Match 'https://crmshow'
    }
    It 'promotes the tested artifact to PROD rather than re-exporting DEV' {
        $workflow = Join-Path $script:root '.github\workflows\cd-solution-prod.yml'
        Test-Path $workflow | Should -BeTrue
        $source = Get-Content $workflow -Raw
        $source | Should -Match 'environment:\s*prod'
        $source | Should -Match 'run-id:'
        $source | Should -Match 'Test-PlatformConnection'
        $source | Should -Not -Match 'Export-Solution'
    }
}
