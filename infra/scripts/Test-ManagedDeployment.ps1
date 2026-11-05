[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$ArtifactPath,
    [Parameter(Mandatory)] [string]$ExpectedSha,
    [Parameter(Mandatory)] [ValidateSet('test', 'prod')] [string]$Slot,
    [Parameter(Mandatory)] [string]$TenantId,
    [Parameter(Mandatory)] [string]$EnvironmentUrl,
    [Parameter(Mandatory)] [string]$OrganizationId
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Get-ManagedRelease.ps1')
. (Join-Path $PSScriptRoot 'PlatformConnection.ps1')
$release = Get-ManagedRelease -ArtifactPath $ArtifactPath -ExpectedSha $ExpectedSha -ForProduction:($Slot -eq 'prod')
Test-PlatformConnection -Slot $Slot -TenantId $TenantId -EnvironmentUrl $EnvironmentUrl `
    -OrganizationId $OrganizationId | Out-Null
$base = Get-NormalizedPlatformUrl $EnvironmentUrl
$token = Get-PlatformAccessToken -TenantId $TenantId -EnvironmentUrl $base
try {
    foreach ($solution in $release.solutions) {
        $name = $solution.name
        if ($release.mode -eq 'StageForUpgrade') { $name += '_Upgrade' }
        $response = Invoke-RestMethod "$base/api/data/v9.2/solutions?`$select=uniquename,version,ismanaged&`$filter=uniquename eq '$name'" `
            -Headers @{ Authorization = "Bearer $token" }
        $actual = @($response.value)
        if ($actual.Count -ne 1 -or -not $actual[0].ismanaged -or $actual[0].version -ne $solution.version) {
            throw "Deployment smoke failed for ${name}: expected managed version $($solution.version)."
        }
    }
    Write-Output "Managed package versions verified in $Slot."
} finally {
    $token = $null
}
