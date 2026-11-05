<#
.SYNOPSIS
    Add configured CI identities to verified Dataverse environments.
.DESCRIPTION
    Uses private application IDs, never display-name selection or legacy URLs.
    Verify the tenant and WhoAmI organization before any application-user write.
    TEST and PROD require the deployment-administrator role for managed imports.
    Run with -WhatIf to review the selected targets without authenticating.
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [ValidateSet('dev', 'test', 'prod', 'all')] [string]$Slot = 'all',
    [string]$ConfigurationPath = (Join-Path $PSScriptRoot '..\..\.platform.local.json')
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'PlatformConnection.ps1')
$config = Get-PlatformConfiguration -Path $ConfigurationPath
$slots = if ($Slot -eq 'all') { @('dev', 'test', 'prod') } else { @($Slot) }
foreach ($name in $slots) {
    Assert-PlatformGuid $config.environments[$name].clientId "$name.clientId"
}
foreach ($name in $slots) {
    $target = $config.environments[$name]
    if (-not $PSCmdlet.ShouldProcess($target.url, "Bootstrap $name CI application user")) { continue }
    $currentTenant = & az account show --query tenantId --output tsv --only-show-errors
    if ($LASTEXITCODE -ne 0 -or $currentTenant.Trim() -ne $config.tenantId) {
        throw 'Azure CLI default tenant does not match the configured tenant.'
    }
    $spJson = & az ad sp show --id $target.clientId --output json --only-show-errors
    if ($LASTEXITCODE -ne 0) { throw "Cannot resolve the configured $name service principal." }
    $sp = $spJson | ConvertFrom-Json
    if ($sp.appId -ne $target.clientId -or -not $sp.id) { throw 'Service principal identity mismatch.' }

    $token = Get-PlatformAccessToken -TenantId $config.tenantId -EnvironmentUrl $target.url
    try {
        $headers = @{ Authorization = "Bearer $token"; 'OData-Version' = '4.0'; Prefer = 'return=representation' }
        $base = "$($target.url)/api/data/v9.2"
        $identity = Invoke-RestMethod "$base/WhoAmI" -Headers $headers
        Assert-PlatformIdentity $config $name $config.tenantId $identity.OrganizationId
        $units = Invoke-RestMethod "$base/businessunits?`$filter=_parentbusinessunitid_value eq null&`$select=businessunitid" -Headers $headers
        if (@($units.value).Count -ne 1) { throw "Expected one root business unit for $name." }
        $rootUnitId = $units.value[0].businessunitid
        $users = Invoke-RestMethod "$base/systemusers?`$filter=applicationid eq $($target.clientId)&`$select=systemuserid" -Headers $headers
        if (@($users.value).Count -gt 1) { throw "Ambiguous application user for $name." }
        if (@($users.value).Count -eq 1) {
            $userId = $users.value[0].systemuserid
        } else {
            $body = @{
                applicationid = $target.clientId
                azureactivedirectoryobjectid = $sp.id
                'businessunitid@odata.bind' = "/businessunits($rootUnitId)"
            } | ConvertTo-Json
            $user = Invoke-RestMethod "$base/systemusers" -Method Post -Headers $headers `
                -ContentType 'application/json' -Body $body
            $userId = $user.systemuserid
            Assert-PlatformGuid $userId 'Created application user ID'
        }
        $roleName = if ($name -eq 'dev') { 'System Customizer' } else { 'System Administrator' }
        $roles = Invoke-RestMethod "$base/roles?`$filter=name eq '$roleName' and _businessunitid_value eq $rootUnitId&`$select=roleid" -Headers $headers
        if (@($roles.value).Count -ne 1) { throw "Expected exactly one root $roleName role for $name." }
        $roleId = $roles.value[0].roleid
        $assigned = Invoke-RestMethod "$base/systemusers($userId)/systemuserroles_association?`$select=roleid" -Headers $headers
        if ($roleId -notin @($assigned.value.roleid)) {
            $body = @{ '@odata.id' = "$base/roles($roleId)" } | ConvertTo-Json
            Invoke-RestMethod "$base/systemusers($userId)/systemuserroles_association/`$ref" `
                -Method Post -Headers $headers -ContentType 'application/json' -Body $body | Out-Null
        }
        Write-Output "Application user and deployment role verified for $name."
    } finally {
        $token = $null
        $headers = $null
    }
}
