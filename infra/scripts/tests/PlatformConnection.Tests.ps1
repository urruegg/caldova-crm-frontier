BeforeAll {
    $script:root = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
    . (Join-Path $script:root 'infra\scripts\PlatformConnection.ps1')
    $script:tenant = '11111111-1111-1111-1111-111111111111'
    $script:org = '22222222-2222-2222-2222-222222222222'
    function New-TestToken([string]$Tenant) {
        $json = @{ tid = $Tenant } | ConvertTo-Json -Compress
        $payload = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($json)).
            TrimEnd('=').Replace('+', '-').Replace('/', '_')
        return "header.$payload.signature"
    }
}
Describe 'Tenant-scoped connection verification' {
    BeforeEach {
        $script:token = New-TestToken $script:tenant
        Mock az { $global:LASTEXITCODE = 0; return $script:token }
        Mock Invoke-RestMethod { @{ OrganizationId = $script:org } }
    }
    It 'checks exactly one explicit target without loading default configuration' {
        Mock Get-PlatformConfiguration { throw 'Default configuration must not be used.' }
        $r = Test-PlatformConnection -Slot prod -TenantId $script:tenant `
            -EnvironmentUrl 'https://unit-prod.crm.dynamics.com' -OrganizationId $script:org
        $r.Slot | Should -Be 'prod'
        $r.Connected | Should -BeTrue
        $r.PSObject.Properties.Name | Should -Not -Contain 'OrganizationId'
        Should -Invoke Invoke-RestMethod -Times 1 -Exactly
    }
    It 'rejects a token from the wrong tenant before calling Dataverse' {
        $script:token = New-TestToken '99999999-9999-9999-9999-999999999999'
        { Test-PlatformConnection -Slot test -TenantId $script:tenant `
            -EnvironmentUrl 'https://unit-test.crm.dynamics.com' -OrganizationId $script:org } |
            Should -Throw '*tenant mismatch*'
        Should -Invoke Invoke-RestMethod -Times 0
    }
    It 'rejects authentication failure rather than emitting a connected result' {
        Mock az { $global:LASTEXITCODE = 1; return '' }
        { Get-PlatformAccessToken -TenantId $script:tenant -EnvironmentUrl 'https://unit.crm.dynamics.com' } |
            Should -Throw '*authentication failed*'
    }
    It 'rejects malformed tokens explicitly' {
        $script:token = 'invalid'
        { Get-PlatformAccessToken -TenantId $script:tenant -EnvironmentUrl 'https://unit.crm.dynamics.com' } |
            Should -Throw '*invalid token*'
    }
    It 'rejects an organization mismatch' {
        Mock Invoke-RestMethod { @{ OrganizationId = '33333333-3333-3333-3333-333333333333' } }
        { Test-PlatformConnection -Slot dev -TenantId $script:tenant `
            -EnvironmentUrl 'https://unit-dev.crm.dynamics.com' -OrganizationId $script:org } |
            Should -Throw '*organization mismatch*'
    }
}

Describe 'Live managed-deployment smoke evaluator' {
    BeforeEach {
        $script:dir = Join-Path $TestDrive ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory $script:dir | Out-Null
        $zip = Join-Path $script:dir 'crmshow_Foundation_managed.zip'
        Set-Content $zip 'synthetic artifact'
        @{
            sourceSha = ('a' * 40); mode = 'InstallOrUpdate'
            solutions = @(@{
                name = 'crmshow_Foundation'; file = 'crmshow_Foundation_managed.zip'
                version = '1.2.0.0'; sha256 = (Get-FileHash $zip).Hash
            })
        } | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $script:dir 'release.json')
        $script:token = New-TestToken $script:tenant
        Mock az { $global:LASTEXITCODE = 0; New-TestToken '11111111-1111-1111-1111-111111111111' }
        Mock Invoke-RestMethod {
            param($Uri)
            if ($Uri -like '*/WhoAmI') { return @{ OrganizationId = '22222222-2222-2222-2222-222222222222' } }
            return @{ value = @(@{ uniquename = 'crmshow_Foundation'; version = '1.2.0.0'; ismanaged = $true }) }
        }
        $script:smoke = Join-Path $script:root 'infra\scripts\Test-ManagedDeployment.ps1'
    }
    It 'checks managed versions in the requested PROD target' {
        { & $script:smoke -ArtifactPath $script:dir -ExpectedSha ('a' * 40) -Slot prod `
            -TenantId $script:tenant -EnvironmentUrl 'https://unit-prod.crm.dynamics.com' -OrganizationId $script:org } |
            Should -Not -Throw
        Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
            $Uri -like 'https://unit-prod.crm.dynamics.com/*solutions*'
        }
    }
    It 'fails when the imported version is not the tested version' {
        Mock Invoke-RestMethod {
            param($Uri)
            if ($Uri -like '*/WhoAmI') { return @{ OrganizationId = '22222222-2222-2222-2222-222222222222' } }
            return @{ value = @(@{ version = '1.1.0.0'; ismanaged = $true }) }
        }
        { & $script:smoke -ArtifactPath $script:dir -ExpectedSha ('a' * 40) -Slot prod `
            -TenantId $script:tenant -EnvironmentUrl 'https://unit-prod.crm.dynamics.com' -OrganizationId $script:org } |
            Should -Throw '*smoke failed*'
    }
}
