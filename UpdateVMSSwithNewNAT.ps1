#Parameter
$resourceGroupName = "<TargetRG>"
$vmssName = "<TargetVMSS>"
$newinboundnatpool = "/subscriptions/xxxx/resourceGroups/xxxxx/providers/Microsoft.Network/loadBalancers/xxxxx/inboundNatPools/xxxxxxxxx"

#Update VMSS Network Config
$targetVmss = Get-AzureRmVmss -ResourceGroupName $resourceGroupName -VMScaleSetName $vmssName
$oldConfig = $targetVmss.VirtualMachineProfile.NetworkProfile.NetworkInterfaceConfigurations[0].IpConfigurations[0]

$newvmssipconfig = New-AzureRmVmssIpConfig -Name $oldConfig.Name`
  -LoadBalancerBackendAddressPoolsId  $oldConfig.LoadBalancerBackendAddressPools[0].Id `
  -LoadBalancerInboundNatPoolsId @($oldConfig.LoadBalancerInboundNatPools[0].Id, $newinboundnatpool) `
  -SubnetId $oldConfig.Subnet.Id

$targetVmss.VirtualMachineProfile.NetworkProfile.NetworkInterfaceConfigurations[0].IpConfigurations[0] = $newvmssipconfig
Update-AzureRmVmss -ResourceGroupName $resourceGroupName -VMScaleSetName $vmssName -VirtualMachineScaleSet $targetVmss

#Manual Upgrade for each instances
Get-AzureRmVmssVM -ResourceGroupName $resourceGroupName -Name $vmssName | Update-AzureRmVmssInstance -ResourceGroupName $resourceGroupName -VMScaleSetName $vmssName 