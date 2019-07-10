#Parameter
$VMLocalAdminUser = "AzureUser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "Azure_Admin_XXXX" -AsPlainText -Force
$LocationName = "WestCentralUS"
$ResourceGroupName = "MyRG"
$ComputerName = "MyVM"
$VMName = "MyVM"
$VMSize = "Standard_DS1_v2"
$NetworkName = "MyNet"
$NICName = "MyNIC"
$SubnetName = "MySubnet"
$OSDiskName = "MyOSDisk"
$OSImage = "/subscriptions/xxxxxx-xxx-xxx-xxx-xxxx/resourceGroups/xxxx/providers/Microsoft.Compute/images/xxx"
$SubnetAddressPrefix = "10.0.0.0/24"
$VnetAddressPrefix = "10.0.0.0/16"

$Vnet = Get-AzVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $Vnet.Subnets[0].Id

$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Linux -ComputerName $ComputerName -Credential $Credential
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -Id $OSImage
$VirtualMachine = Set-AzVMOSDisk  -VM $VirtualMachine -Name $OSDiskName -CreateOption "FromImage"

New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Debug