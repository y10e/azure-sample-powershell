#Parameter
$resourceGroupName = "<resourceGroupName>" # ResourceGroup Name of VMSS & LB 
$vmssName = "<VMScalesetName>" #VMSS Name
$newLBName = "<LoadBalancerNama>" #LBName

#Get New LoadBalancer Infomation
$LB = Get-AzureRmLoadBalancer -ResourceGroupName $resourceGroupName -Name $newLBName
$LB.BackendAddressPools[0].Id

#Update VMSS Network Config
$targetVmss = Get-AzureRmVmss -ResourceGroupName $resourceGroupName -VMScaleSetName $vmssName
$oldConfig = $targetVmss.VirtualMachineProfile.NetworkProfile.NetworkInterfaceConfigurations[0].IpConfigurations[0]

$newvmssipconfig = New-AzureRmVmssIpConfig -Name $oldConfig.Name`
  -LoadBalancerBackendAddressPoolsId  $LB.BackendAddressPools[0].Id `
  -SubnetId $oldConfig.Subnet.Id

$targetVmss.VirtualMachineProfile.NetworkProfile.NetworkInterfaceConfigurations[0].IpConfigurations[0] = $newvmssipconfig
Update-AzureRmVmss -ResourceGroupName $resourceGroupName -VMScaleSetName $vmssName -VirtualMachineScaleSet $targetVmss

#Manual Upgrade for each instances
Get-AzureRmVmssVM -ResourceGroupName $resourceGroupName -Name $vmssName | Update-AzureRmVmssInstance -ResourceGroupName $resourceGroupName -VMScaleSetName $vmssName