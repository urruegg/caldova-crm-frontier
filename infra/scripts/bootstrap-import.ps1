<#
.SYNOPSIS
    Import the three existing, verified environments into isolated Caldova state.
.DESCRIPTION
    Never creates environments or applies Terraform. The caller must initialize
    the Caldova local backend and supply a complete private var-file first.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ConfigurationPath = (Join-Path $PSScriptRoot '..\..\.platform.local.json'),
    [Parameter(Mandatory)] [string]$VariableFile,
    [string]$TerraformDir = (Join-Path $PSScriptRoot '..\terraform')
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'PlatformConnection.ps1')
$ConfigurationPath = (Resolve-Path -LiteralPath $ConfigurationPath).Path
$config = Get-PlatformConfiguration -Path $ConfigurationPath
$variables = Get-Content -LiteralPath $VariableFile -Raw | ConvertFrom-Json -AsHashtable
if ($variables.manage_environments -ne $true) {
    throw 'Environment import requires an approved manage_environments=true var-file. Reference-only mode needs no import.'
}
if ($variables.tenant_id -ne $config.tenantId) { throw 'Terraform var-file tenant mismatch.' }
foreach ($slot in @('dev', 'test', 'prod')) {
    if ($variables.environments[$slot].id -ne $config.environments[$slot].environmentId) {
        throw "Terraform var-file environment mismatch for $slot."
    }
}
$fullVarFile = (Resolve-Path $VariableFile).Path
Push-Location $TerraformDir
try {
    foreach ($slot in @('dev', 'test', 'prod')) {
        $address = "module.powerplatform.powerplatform_environment.this[`"$slot`"]"
        if (-not $PSCmdlet.ShouldProcess($address, 'Import verified existing environment into Caldova state')) { continue }
        Test-PlatformConnection -ConfigurationPath $ConfigurationPath -Slot $slot | Out-Null
        $state = @()
        if (Test-Path -LiteralPath '.terraform-caldova\terraform.tfstate') {
            $state = & terraform state list
            if ($LASTEXITCODE -ne 0) { throw 'Cannot read isolated Terraform state. Initialize the Caldova backend first.' }
        }
        if ($address -in @($state)) {
            $current = & terraform show -json | ConvertFrom-Json
            if ($LASTEXITCODE -ne 0) { throw 'Cannot verify existing Terraform state.' }
            $resource = @($current.values.root_module.child_modules |
                Where-Object address -eq 'module.powerplatform').resources |
                Where-Object address -eq $address
            if ($resource.values.id -ne $config.environments[$slot].environmentId) {
                throw "Existing state does not match configured environment $slot."
            }
            Write-Output "Verified existing import for $slot."
        } else {
            & terraform import "-var-file=$fullVarFile" $address $config.environments[$slot].environmentId
            if ($LASTEXITCODE -ne 0) { throw "Terraform import failed for $slot." }
        }
    }
} finally {
    Pop-Location
}
