﻿# -------------
# Script to deploy Chef Automate and dependent services to Microsoft Azure
#
#
# Written by: John Snow, The Lunatic Scripter
#
#
# Licensed under the Apache 2.0 Creative commons License
#
#
# -------------

function New-RandomString {
    $String = $null
    $r = New-Object System.Random
    1..6 | % { $String += [char]$r.next(97,122) }
    $string
}

### Define variables For Chef server and other deployments

$SubscriptionName = 'Visual Studio Ultimate with MSDN'
$Location = 'East US' ### Use "Get-AzureLocation | Where-Object Name -eq 'ResourceGroup' | Format-Table Name, LocationsString -Wrap" in ARM mode to find locations which support Resource Groups
$GroupName = 'chef-lab'
$DeploymentName = 'chef-server-deployment'
$StorageName = 'chefstorage' 
$PublicDNSName = 'chef-lab-' + (New-RandomString)
$AdminUsername = 'chef'

### Connect to Azure account

if (Get-AzureSubscription){
    Get-AzureSubscription -SubscriptionName $SubscriptionName | Select-AzureSubscription -Verbose
    }
    else {
    Add-AzureAccount
    Get-AzureSubscription -SubscriptionName $SubscriptionName | Select-AzureSubscription -Verbose
    }

#Switch-AzureMode AzureResourceManager -Verbose

Login-AzureRmAccount

### Create Resource Group ###

if((Get-AzureRmResourceGroup -ResourceGroupName $GroupName).Count -eq 0){
    New-AzureRmResourceGroup -Name $GroupName -Location $Location -Verbose
    $ResourceGroup = Get-AzureRmResourceGroup -Name $GroupName
    }
    else {$ResourceGroup = Get-AzureRmResourceGroup -Name $GroupName}

### Get Resource Group ###
$AzureResourceGroup = Get-AzureRmResourceGroup -Name $GroupName
Write-Host 'Resource Group Name is'$AzureResourceGroup.ResourceGroupName

### Get Storage Account ###

if((Get-AzureRmStorageAccount).StorageAccountName -like "*chefstorage*"){
    Write-Host "Storage Account exsists"
    $AzureStorageAccount = Get-AzureRmStorageAccount | where {$_.StorageAccountName -like "*chefstorage*"}
    
}
else{
    $AzureStorageAccount = $StorageName + (New-RandomString)
}
Write-Host 'Storage Account is' $AzureStorageAccount.StorageAccountName

$parameters = @{
    'newStorageAccountName'="$($AzureStorageAccount.StorageAccountName)";
    'adminUsername'="$AdminUsername";
    'dnsNameForPublicIP'="$PublicDNSName";
    }

# Deploy Chef Server
New-AzureRmResourceGroupDeployment `
    -Name $DeploymentName `
    -ResourceGroupName $ResourceGroup.ResourceGroupName `
    -TemplateFile azure_chefsrv.json `
    -TemplateParameterObject $parameters `
    -Verbose

# Deploy Chef Automate Server
### Define variables

### Get Virtual Network ###
$AzureVirtualNetwork = ($AzureResourceGroup | Get-AzureRmVirtualNetwork).Name
Write-Host 'Virtual Network is' $AzureVirtualNetwork

$DeploymentName = 'chef-auto-deployment'
$PublicDNSName = 'chef-lab-' + (New-RandomString)
$AdminUsername = 'chef'

$parameters = @{
    'StorageAccountName'="$($AzureStorageAccount.StorageAccountName)";
    'adminUsername'="$AdminUsername";
    'dnsNameForPublicIP'="$PublicDNSName";
    'virtualNetworkName'="$AzureVirtualNetwork"
    }

New-AzureRmResourceGroupDeployment `
    -Name $DeploymentName `
    -ResourceGroupName $AzureResourceGroup.ResourceGroupName `
    -TemplateFile azure_chefauto.json `
    -TemplateParameterObject $parameters `
    -Verbose

# Deploy Chef Compliance Server
### Define variables

$DeploymentName = 'chef-cmpl-deployment'
$PublicDNSName = 'chef-lab-' + (New-RandomString)
$AdminUsername = 'chef'

$parameters = @{
    'StorageAccountName'="$($AzureStorageAccount.StorageAccountName)";
    'adminUsername'="$AdminUsername";
    'dnsNameForPublicIP'="$PublicDNSName";
    'virtualNetworkName'="$AzureVirtualNetwork"
    }

New-AzureRmResourceGroupDeployment `
    -Name $DeploymentName `
    -ResourceGroupName $AzureResourceGroup.ResourceGroupName `
    -TemplateFile azure_chefcmpl.json `
    -TemplateParameterObject $parameters `
    -Verbose

# Deploy Chef Windows Management Server
### Define variables

$DeploymentName = 'chef-win-deployment'
$PublicDNSName = 'chef-lab-' + (New-RandomString)
$AdminUsername = 'chef'

$parameters = @{
    'StorageAccountName'="$($AzureStorageAccount.StorageAccountName)";
    'adminUsername'="$AdminUsername";
    'dnsNameForPublicIP'="$PublicDNSName";
    'virtualNetworkName'="$AzureVirtualNetwork"
    }

New-AzureRmResourceGroupDeployment `
    -Name $DeploymentName `
    -ResourceGroupName $AzureResourceGroup.ResourceGroupName `
    -TemplateFile azure_winmgmt.json `
    -TemplateParameterObject $parameters `
    -Verbose

# Deploy Chef First Build Node
### Define variables

$DeploymentName = 'chef-bld1-deployment'
$PublicDNSName = 'chef-lab-' + (New-RandomString)
$AdminUsername = 'chef'

$parameters = @{
    'StorageAccountName'="$($AzureStorageAccount.StorageAccountName)";
    'adminUsername'="$AdminUsername";
    'dnsNameForPublicIP'="$PublicDNSName";
    'virtualNetworkName'="$AzureVirtualNetwork"
    }

New-AzureRmResourceGroupDeployment `
    -Name $DeploymentName `
    -ResourceGroupName $AzureResourceGroup.ResourceGroupName `
    -TemplateFile azure_chefbld1.json `
    -TemplateParameterObject $parameters `
    -Verbose

# Deploy Chef Second Build Node
### Define variables

$DeploymentName = 'chef-bld2-deployment'
$PublicDNSName = 'chef-lab-' + (New-RandomString)
$AdminUsername = 'chef'

$parameters = @{
    'StorageAccountName'="$($AzureStorageAccount.StorageAccountName)";
    'adminUsername'="$AdminUsername";
    'dnsNameForPublicIP'="$PublicDNSName";
    'virtualNetworkName'="$AzureVirtualNetwork"
    }

New-AzureRmResourceGroupDeployment `
    -Name $DeploymentName `
    -ResourceGroupName $AzureResourceGroup.ResourceGroupName `
    -TemplateFile azure_chefbld2.json `
    -TemplateParameterObject $parameters `
    -Verbose
    
# Deploy Chef Supermarket
### Define variables
$DeploymentName = 'chef-sup-deployment'
$PublicDNSName = 'chef-lab-' + (New-RandomString)
$AdminUsername = 'chef'

$parameters = @{
    'StorageAccountName'="$($AzureStorageAccount.StorageAccountName)";
    'adminUsername'="$AdminUsername";
    'dnsNameForPublicIP'="$PublicDNSName";
    'virtualNetworkName'="$AzureVirtualNetwork"
    }

New-AzureRmResourceGroupDeployment `
    -Name $DeploymentName `
    -ResourceGroupName $AzureResourceGroup.ResourceGroupName `
    -TemplateFile azure_chefmkt.json `
    -TemplateParameterObject $parameters `
    -Verbose