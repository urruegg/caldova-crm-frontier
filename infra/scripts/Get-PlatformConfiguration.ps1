function Assert-PlatformGuid {
    param([string]$Value, [string]$Name)
    $parsed = [guid]::Empty
    if (-not [guid]::TryParse($Value, [ref]$parsed) -or $parsed -eq [guid]::Empty) {
        throw "$Name must be a non-empty GUID, not a placeholder."
    }
}

function Get-NormalizedPlatformUrl {
    param([string]$Value)
    $uri = $null
    if (-not [uri]::TryCreate($Value, [UriKind]::Absolute, [ref]$uri) -or
        $uri.Scheme -ne 'https' -or
        $uri.Host -notmatch '^[a-z0-9-]+\.crm[0-9]*\.dynamics\.com$' -or
        -not $uri.IsDefaultPort -or $uri.UserInfo -or
        $uri.AbsolutePath -ne '/' -or $uri.Query -or $uri.Fragment) {
        throw 'Dataverse endpoint must be an HTTPS organisation root URL.'
    }
    return $uri.GetLeftPart([UriPartial]::Authority).ToLowerInvariant()
}

function Get-PlatformConfiguration {
    [CmdletBinding()]
    param([string]$Path = (Join-Path $PSScriptRoot '..\..\.platform.local.json'))

    $config = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop |
        ConvertFrom-Json -AsHashtable -ErrorAction Stop
    Assert-PlatformGuid -Value $config.tenantId -Name 'tenantId'
    if ($config.environments -isnot [System.Collections.IDictionary] -or
        (@($config.environments.Keys | Sort-Object) -join ',') -ne 'dev,prod,test') {
        throw 'Platform configuration must contain exactly dev, test and prod.'
    }
    foreach ($slot in @('dev', 'test', 'prod')) {
        $target = $config.environments[$slot]
        $target.url = Get-NormalizedPlatformUrl -Value $target.url
        Assert-PlatformGuid -Value $target.environmentId -Name "$slot.environmentId"
        Assert-PlatformGuid -Value $target.organizationId -Name "$slot.organizationId"
        if ($target.clientId) {
            Assert-PlatformGuid -Value $target.clientId -Name "$slot.clientId"
        }
    }
    foreach ($field in @('url', 'environmentId', 'organizationId')) {
        $values = @($config.environments.Values | ForEach-Object { $_[$field] } | Sort-Object -Unique)
        if ($values.Count -ne 3) { throw "Environment $field values must be distinct." }
    }
    $clients = @($config.environments.Values | ForEach-Object { $_.clientId } | Where-Object { $_ })
    if (@($clients | Sort-Object -Unique).Count -ne $clients.Count) {
        throw 'Configured CI client identities must be distinct per environment.'
    }
    return $config
}

function Assert-PlatformIdentity {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $Configuration,
        [Parameter(Mandatory)] [ValidateSet('dev', 'test', 'prod')] [string]$Slot,
        [Parameter(Mandatory)] [string]$TokenTenantId,
        [Parameter(Mandatory)] [string]$OrganizationId
    )
    if ($TokenTenantId -ne $Configuration.tenantId) {
        throw "Platform tenant mismatch for $Slot. No mutation is permitted."
    }
    if ($OrganizationId -ne $Configuration.environments[$Slot].organizationId) {
        throw "Platform organization mismatch for $Slot. No mutation is permitted."
    }
}
