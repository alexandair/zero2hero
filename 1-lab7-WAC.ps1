# LAB: Windows Admin Center

# The goal of this lab is to access Windows Admin Center on the windowsmgmt VM from your computer
# and add VM Scale Set instances as managed nodes

#region Define variables

$resourceGroupName = 'otp-vms-rg'

#endregion

# Find out the VM Scale Set InstanceIDs
Get-AzVmssVM -ResourceGroupName $resourceGroupName -VMScaleSetName demoscaleset |
Select-Object -ExpandProperty InstanceId -OutVariable InstanceIDs

# windowmgmt VM and VM scale set instances are in the different subnets
# you need to modify a scope for the public profile of Windows Remote Management rule on the target instances
code .\EnableAccessFromWindowsmgmtVM.ps1

Invoke-AzVmssVMRunCommand -ResourceGroupName $resourceGroupName -VMScaleSetName 'demoScaleSet' -InstanceId $InstanceIDs[0] -CommandId 'RunPowerShellScript' -ScriptPath 'EnableAccessFromWindowsmgmtVM.ps1'
<# OUTPUT
Value[0]        :
  Code          : ComponentStatus/StdOut/succeeded
  Level         : Info
  DisplayStatus : Provisioning succeeded
  Message       :
Value[1]        :
  Code          : ComponentStatus/StdErr/succeeded
  Level         : Info
  DisplayStatus : Provisioning succeeded
  Message       :
Status          : Succeeded
Capacity        : 0
Count           : 0
#>

Invoke-AzVmssVMRunCommand -ResourceGroupName $resourceGroupName -VMScaleSetName 'demoScaleSet' -InstanceId $InstanceIDs[1] -CommandId 'RunPowerShellScript' -ScriptPath 'EnableAccessFromWindowsmgmtVM.ps1'

# Get the public IP of the linuxjumpbox VM
$PublicIP = (Get-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name linuxjumpbox-ip).IpAddress

cd ~/.ssh
az ssh config --file config --ip $publicIP

# Magic of a port forwarding; WAC on windowsmgmt VM is listening on port 6516 (by default)
ssh -L 6515:192.168.2.4:6516 $PublicIP -N

# Open WAC (https://localhost:6515) and add VM Scale Set instances using their private IP addresses (192.168.3.4 and 192.168.3.5)
 

