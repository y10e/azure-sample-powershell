#Parameter
$vmresourceGroupName = "xxx"　#リソースグループ名
$vmname = "xxx" #VM名
$strresourcegroupname = "xxx" #ストレージアカウントリソースグループ名
$storageaccountName = "xxx" #ストレージアカウント名

# Login
Login-AzureRmAccount
$mySub = Get-AzureRmSubscription | Out-GridView -Title "Select an Azure Subscription ..." -PassThru
Select-AzureRmSubscription -SubscriptionId $mySub.Id

# Get VM details including LAD's storage account
$vm = get-azurermvm -resourceGroupName $vmresourceGroupName -Name $vmName
$location = $vm.location

# Remove existing version of LAD - IF ANY
remove-AzureRmVMExtension -ResourceGroupName $vmresourceGroupName -VMName $vmName -Name 'LinuxDiagnostic' -force

# Install LAD 2.3
$storageAccountKey = ((Get-AzureRmStorageAccountKey -ResourceGroupName $strresourceGroupName -Name $storageAccountName) | where KeyName -eq 'key1').value
$ProtectedSettings = @{"storageAccountName" = $storageaccountName; "storageAccountKey" = $storageAccountKey};
$xmlCfg = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("<WadCfg></WadCfg>"))
$Settings = @{StorageAccount = $storageaccountName; xmlCfg = $xmlCfg}
Set-AzureRmVMExtension -ResourceGroupName $vmresourceGroupName -VMName $vmname -Publisher "Microsoft.OSTCExtensions" -ExtensionType "LinuxDiagnostic" -TypeHandlerVersion "2.3" -Name "LinuxDiagnostic" -Settings $Settings -ProtectedSettings $ProtectedSettings -Location $location
