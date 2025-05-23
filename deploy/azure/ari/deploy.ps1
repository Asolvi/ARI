[CmdletBinding()]
param (    
    [Parameter(Mandatory = $true)]
    [ValidateSet('dev','prod')]
    [string]$envName,
    
    [string]$location = "westeurope",
    
    [switch]$whatIf,

    [switch]$build,

    [string]$managementGroupId = "ac934dd1-86d1-4053-a485-ad39d829abad"
)

enum Environment {
    dev
    prod
}

$ErrorActionPreference = "Stop"

[Environment]$env = [Environment]$envName

#
# set subscription
#
if ($env -eq [Environment]::prod) {
    $subscriptionName = "Platform Prod"
}
else {
    $subscriptionName = "Platform DevTest"
}

az account set -s $subscriptionName
$name = az account show --query name -o tsv

if ($subscriptionName -ne $name) {
    Write-Error "Failed to find account"
    exit 1
}

Write-Host $name

switch ($location.ToLower().Replace(' ', '')) {
    'westeurope' { $locationAbbreviation = 'weu' }
    Default { $locationAbbreviation = 'unkwown' }
}

#
# deploy template to a management group
#
$deploymentName = "pf-ari-${env}-${locationAbbreviation}-init-deploy"
$templateFile = "${PSScriptRoot}\main.bicep"
$params = "${PSScriptRoot}\parameters\deploy-${env}.parameters.bicepparam"

if ($build) {
    az bicep build -f $templateFile
    return
}

if ($whatIf) {
    az deployment mg what-if `
        --management-group-id $managementGroupId `
        --location $location `
        --name $deploymentName `
        --template-file $templateFile `
        --parameters $params `
        -o yamlc
}
else {
    az deployment mg create `
        --management-group-id $managementGroupId `
        --location $location `
        --name $deploymentName `
        --template-file $templateFile `
        --parameters $params `
        -o yamlc
}