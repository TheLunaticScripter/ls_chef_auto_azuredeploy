# -------------
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

### Define variables

$SubscriptionName = 'Visual Studio Ultimate with MSDN'
$Location = 'East US' ### Use "Get-AzureLocation | Where-Object Name -eq 'ResourceGroup' | Format-Table Name, LocationsString -Wrap" in ARM mode to find locations which support Resource Groups
$GroupName = 'chef-lab'
$DeploymentName = 'chef-server-deployment'
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

if((Get-AzureRmResourceGroup -ResourceGroupName $GroupName) -eq $false){
    New-AzureRmResourceGroup -Name $GroupName -Location $Location -Verbose
    $ResourceGroup = Get-AzureRmResourceGroup -Name $GroupName
    }
    else {$ResourceGroup = Get-AzureRmResourceGroup -Name $GroupName}

### Get Resource Group ###
$AzureResourceGroup = Get-AzureRmResourceGroup -Name $GroupName
Write-Host 'Resource Group Name is'$AzureResourceGroup.ResourceGroupName

### Get Storage Account ###
$AzureStorageAccount = ($AzureResourceGroup | Get-AzureRmStorageAccount).StorageAccountName
Write-Host 'Storage Account is' $AzureStorageAccount

### Get Virtual Network ###
$AzureVirtualNetwork = ($AzureResourceGroup | Get-AzureRmVirtualNetwork).Name
Write-Host 'Virtual Network is' $AzureVirtualNetwork

$parameters = @{
    'StorageAccountName'="$AzureStorageAccount";
    'adminUsername'="$AdminUsername";
    'dnsNameForPublicIP'="$PublicDNSName";
    'virtualNetworkName'="$AzureVirtualNetwork"
    }

New-AzureRmResourceGroupDeployment `
    -Name $DeploymentName `
    -ResourceGroupName $ResourceGroup.ResourceGroupName `
    -TemplateFile azure_chefsrv.json `
    -TemplateParameterObject $parameters `
    -Verbose

### Define variables

$DeploymentName = 'chef-auto-deployment'
$PublicDNSName = 'chef-lab-' + (New-RandomString)
$AdminUsername = 'chef'

$parameters = @{
    'StorageAccountName'="$AzureStorageAccount";
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

### Define variables

$DeploymentName = 'chef-auto-deployment'
$PublicDNSName = 'chef-lab-' + (New-RandomString)
$AdminUsername = 'chef'

$parameters = @{
    'StorageAccountName'="$AzureStorageAccount";
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
