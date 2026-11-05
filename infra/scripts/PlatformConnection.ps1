. (Join-Path $PSScriptRoot 'Get-PlatformConfiguration.ps1')

function Get-PlatformAccessToken {
    [CmdletBinding()]
    param([string]$TenantId, [string]$EnvironmentUrl)

    $token = & az account get-access-token --tenant $TenantId --resource "$EnvironmentUrl/" `
        --query accessToken --output tsv --only-show-errors
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($token)) {
        throw 'Platform authentication failed. Sign in to the configured tenant.'
    }
    $parts = $token.Trim().Split('.')
    if ($parts.Count -ne 3) { throw 'Platform authentication returned an invalid token.' }
    $payload = $parts[1].Replace('-', '+').Replace('_', '/')
    $payload = $payload.PadRight($payload.Length + ((4 - $payload.Length % 4) % 4), '=')
    $claims = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload)) | ConvertFrom-Json
    if ($claims.tid -ne $TenantId) { throw 'Platform token tenant mismatch.' }
    return $token.Trim()
}

function Test-PlatformConnection {
    [CmdletBinding(DefaultParameterSetName = 'Configuration')]
    param(
        [Parameter(ParameterSetName = 'Configuration')]
        [string]$ConfigurationPath = (Join-Path $PSScriptRoot '..\..\.platform.local.json'),
        [ValidateSet('dev', 'test', 'prod', 'all')] [string]$Slot = 'all',
        [Parameter(Mandatory, ParameterSetName = 'Target')] [string]$TenantId,
        [Parameter(Mandatory, ParameterSetName = 'Target')] [string]$EnvironmentUrl,
        [Parameter(Mandatory, ParameterSetName = 'Target')] [string]$OrganizationId
    )
    $ErrorActionPreference = 'Stop'
    if ($PSCmdlet.ParameterSetName -eq 'Target') {
        Assert-PlatformGuid $TenantId 'tenantId'
        Assert-PlatformGuid $OrganizationId 'organizationId'
        if ($Slot -eq 'all') { throw 'Select one slot when checking an explicit target.' }
        $config = @{ tenantId = $TenantId; environments = @{} }
        $config.environments[$Slot] = @{
            url = Get-NormalizedPlatformUrl $EnvironmentUrl
            organizationId = $OrganizationId
        }
        $slots = @($Slot)
    } else {
        $config = Get-PlatformConfiguration -Path $ConfigurationPath
        $slots = if ($Slot -eq 'all') { @('dev', 'test', 'prod') } else { @($Slot) }
    }
    foreach ($name in $slots) {
        $target = $config.environments[$name]
        $token = Get-PlatformAccessToken -TenantId $config.tenantId -EnvironmentUrl $target.url
        try {
            $identity = Invoke-RestMethod -Method Get -Uri "$($target.url)/api/data/v9.2/WhoAmI" `
                -Headers @{ Authorization = "Bearer $token" }
            Assert-PlatformIdentity -Configuration $config -Slot $name `
                -TokenTenantId $config.tenantId -OrganizationId $identity.OrganizationId
            [pscustomobject]@{ Slot = $name; Connected = $true }
        } finally {
            $token = $null
        }
    }
}
