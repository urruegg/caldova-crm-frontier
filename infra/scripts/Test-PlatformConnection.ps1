[CmdletBinding(DefaultParameterSetName = 'Configuration')]
param(
    [Parameter(ParameterSetName = 'Configuration')]
    [string]$ConfigurationPath = (Join-Path $PSScriptRoot '..\..\.platform.local.json'),
    [ValidateSet('dev', 'test', 'prod', 'all')] [string]$Slot = 'all',
    [Parameter(Mandatory, ParameterSetName = 'Target')] [string]$TenantId,
    [Parameter(Mandatory, ParameterSetName = 'Target')] [string]$EnvironmentUrl,
    [Parameter(Mandatory, ParameterSetName = 'Target')] [string]$OrganizationId
)
. (Join-Path $PSScriptRoot 'PlatformConnection.ps1')
Test-PlatformConnection @PSBoundParameters
