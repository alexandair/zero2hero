# LAB: Create a virtual network and its subnets

<#
In this lab, we will create a virtual network with 3 subnets.
First, create a resource group for the network resources.
In 'jumpbox' subnet, we will later deploy the Linux jumpbox virtual machine.
In 'management' subnet, a Windows management virtual machine.
And finally, in 'frontend' subnet a couple of Windows virtual machines as part of the VM Scale Set. 
#>


#region Define variables

$resourceGroupName = 'otp-net-rg'
$vnetName = 'demovnet'
$location = 'westeurope'

#endregion

#region Authenticate to Azure

Connect-AzAccount

# In case you have access to more than one subscription
# Pick the appropriate subscription, and then set the current context to use it
# All subsequent cmdlets use that subscription by default
Get-AzSubscription | Out-GridView -PassThru | Set-AzContext

Get-AzContext

#endregion


#region Create a VNet with the jumpbox, management, and frontend subnets

New-AzResourceGroup -Name $resourceGroupName -Location $location

$vnet = New-AzVirtualNetwork -Name $vnetName -AddressPrefix 192.168.0.0/16 -ResourceGroupName $resourceGroupName -Location $location

$subnetConfigJB = New-AzVirtualNetworkSubnetConfig -Name jumpbox -AddressPrefix 192.168.1.0/29
$vnet.Subnets.Add($subnetConfigJB)
Set-AzVirtualNetwork -VirtualNetwork $vnet

$subnetConfigMgmt = New-AzVirtualNetworkSubnetConfig -Name management -AddressPrefix 192.168.2.0/24
$vnet.Subnets.Add($subnetConfigMgmt)
Set-AzVirtualNetwork -VirtualNetwork $vnet

$subnetConfigFE = New-AzVirtualNetworkSubnetConfig -Name frontend -AddressPrefix 192.168.3.0/24
$vnet.Subnets.Add($subnetConfigFE)
Set-AzVirtualNetwork -VirtualNetwork $vnet

# Different approach to create multiple subnets

$vnet = New-AzVirtualNetwork -Name $vnetName -AddressPrefix 192.168.0.0/16 -ResourceGroupName $resourceGroupName -Location $location

$subnets = @{
    jumpbox    = '192.168.1.0/29'
    management = '192.168.2.0/24'
    frontend   = '192.168.3.0/24'
}

$subnets.GetEnumerator() | ForEach-Object {
    $subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $_.Name -AddressPrefix $_.Value
    $vnet.Subnets.Add($subnetConfig)
}
    
Set-AzVirtualNetwork -VirtualNetwork $vnet


#endregion

<#
The goal is to secure network access so that only a jumpbox machine has a public IP address.
To accomplish that we will create a couple of network security groups and assign them to the subnets.
Allowed traffic:
1. From internet allow SSH to a jumpbox machine
2. Allow RDP to a Windows management machine only from the jumpbox machine
3. From internet allow access to port 80 on web servers in a VM scale set 
#>

#region Create the network security groups (NSGs)

$MyPublicIp = (Invoke-RestMethod -Uri 'ipinfo.io/json').ip

$ssh = New-AzNetworkSecurityRuleConfig -Name "allow-SSH-from-myaddress" -SourceAddressPrefix $MyPublicIp -SourcePortRange * -Protocol TCP -Access Allow -Priority 110 -Direction Inbound -DestinationAddressPrefix * -DestinationPortRange 22
$ssh2 = New-AzNetworkSecurityRuleConfig -Name "allow-SSH-from-azurecloud" -SourceAddressPrefix "AzureCloud" -SourcePortRange * -Protocol TCP -Access Allow -Priority 120 -Direction Inbound -DestinationAddressPrefix * -DestinationPortRange 22
$rdp = New-AzNetworkSecurityRuleConfig -Name "allow-RDP-from-jumpbox" -SourceAddressPrefix "192.168.1.0/29" -SourcePortRange * -Protocol TCP -Access Allow -Priority 110 -Direction Inbound -DestinationAddressPrefix * -DestinationPortRange 3389
$web = New-AzNetworkSecurityRuleConfig -Name "allow-80-from-internet" -SourceAddressPrefix Internet -SourcePortRange * -Protocol TCP -Access Allow -Priority 110 -Direction Inbound -DestinationAddressPrefix * -DestinationPortRange 80

$jumpbox_nsg = New-AzNetworkSecurityGroup -Name jumpbox_nsg -SecurityRules $ssh,$ssh2 -ResourceGroupName $resourceGroupName -Location $location
$management_nsg = New-AzNetworkSecurityGroup -Name management_nsg -SecurityRules $rdp -ResourceGroupName $resourceGroupName -Location $location
$frontend_nsg = New-AzNetworkSecurityGroup -Name frontend_nsg -SecurityRules $web -ResourceGroupName $resourceGroupName -Location $location

$vnetConfig = Set-AzVirtualNetworkSubnetConfig -Name jumpbox -VirtualNetwork $vnet -NetworkSecurityGroup $jumpbox_nsg -AddressPrefix $subnetConfigJB.AddressPrefix
Set-AzVirtualNetwork -VirtualNetwork $vnetConfig

$vnetConfig = Set-AzVirtualNetworkSubnetConfig -Name management -VirtualNetwork $vnet -NetworkSecurityGroup $management_nsg -AddressPrefix $subnetConfigMgmt.AddressPrefix
Set-AzVirtualNetwork -VirtualNetwork $vnetConfig

$vnetConfig = Set-AzVirtualNetworkSubnetConfig -Name frontend -VirtualNetwork $vnet -NetworkSecurityGroup $frontend_nsg -AddressPrefix $subnetConfigFE.AddressPrefix
Set-AzVirtualNetwork -VirtualNetwork $vnetConfig

#endregion