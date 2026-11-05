function Get-ManagedRelease {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$ArtifactPath,
        [Parameter(Mandatory)] [ValidatePattern('^[0-9a-f]{40}$')] [string]$ExpectedSha,
        [switch]$ForProduction
    )
    $release = Get-Content (Join-Path $ArtifactPath 'release.json') -Raw -ErrorAction Stop |
        ConvertFrom-Json -ErrorAction Stop
    if ($release.sourceSha -ne $ExpectedSha) { throw 'Release source revision mismatch.' }
    if ($release.mode -notin @('InstallOrUpdate', 'StageForUpgrade')) { throw 'Invalid release import mode.' }
    if ($ForProduction -and $release.mode -ne 'InstallOrUpdate') {
        throw 'A staged TEST release cannot be promoted to production.'
    }
    if ($null -eq $release.solutions -or @($release.solutions).Count -eq 0) {
        throw 'Release solution list is empty.'
    }
    $names = @()
    foreach ($solution in $release.solutions) {
        if ($solution.name -notmatch '^[A-Za-z][A-Za-z0-9_]+$' -or
            $solution.file -cne "$($solution.name)_managed.zip") {
            throw 'Invalid managed solution filename.'
        }
        if ($solution.version -notmatch '^\d+\.\d+\.\d+\.\d+$') { throw 'Invalid release solution version.' }
        if ($solution.name -in $names) { throw 'Duplicate release solution name.' }
        $names += $solution.name
        $hash = (Get-FileHash -LiteralPath (Join-Path $ArtifactPath $solution.file) -Algorithm SHA256 -ErrorAction Stop).Hash
        if ($hash -ne $solution.sha256) { throw "Release package hash mismatch: $($solution.name)." }
    }
    return $release
}
