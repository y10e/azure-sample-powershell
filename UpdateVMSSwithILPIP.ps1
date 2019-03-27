#Parameter
$resourceGroupName = "<ResourceGroupName>"
$vmssName = "<ScaleSetName>"

#Update VMSS Network Config
$targetVmss = Get-AzureRmVmss -ResourceGroupName $resourceGroupName -VMScaleSetName $vmssName
$oldConfig = $targetVmss.VirtualMachineProfile.NetworkProfile.NetworkInterfaceConfigurations[0].IpConfigurations[0]

$newvmssipconfig = New-AzureRmVmssIpConfig -Name $oldConfig.Name`
  -LoadBalancerBackendAddressPoolsId  $oldConfig.LoadBalancerBackendAddressPools[0].Id `
  -LoadBalancerInboundNatPoolsId $oldConfig.LoadBalancerInboundNatPools[0].Id `
  -SubnetId $oldConfig.Subnet.Id `
  -PublicIPAddressConfigurationName "instancepublicip" `
  -PublicIPAddressConfigurationIdleTimeoutInMinutes 10 

$targetVmss.VirtualMachineProfile.NetworkProfile.NetworkInterfaceConfigurations[0].IpConfigurations[0] = $newvmssipconfig
Update-AzureRmVmss -ResourceGroupName $resourceGroupName -VMScaleSetName $vmssName -VirtualMachineScaleSet $targetVmss

#Manual Upgrade for each instances
Get-AzureRmVmssVM -ResourceGroupName $resourceGroupName -Name $vmssName | Update-AzureRmVmssInstance -ResourceGroupName $resourceGroupName -VMScaleSetName $vmssName 