#Parameter
$vmresourcegroupname = "xxx"　#仮想マシンリソースグループ名
$vmname = "xxx" #仮想マシン名
$strresourcegroupname = "xxx" #ストレージアカウントリソースグループ名
$storageaccountName = "xxx" #ストレージアカウント名

# Login
Login-AzureRmAccount
$mySub = Get-AzureRmSubscription | Out-GridView -Title "Select an Azure Subscription ..." -PassThru
Select-AzureRmSubscription -SubscriptionId $mySub.Id

# Get VM details including LAD's storage account
$vm = get-azurermvm -resourceGroupName $vmresourceGroupName -Name $vmName
$location = $vm.location

# this is useful if we're UPGRADING from LAD 2.3
#$extension = $vm.extensions | where {$_.VirtualMachineExtensionType -eq 'LinuxDiagnostic'}
#$storageAccountName = ($extension.settings.ToString() | convertfrom-json).StorageAccount
#$storageAccountKey = ((Get-AzureRmStorageAccountKey -ResourceGroupName $strresourceGroupName -Name $storageAccountName) | where KeyName -eq 'key1').value

# update
$storageAccountKey = ((Get-AzureRmStorageAccountKey -ResourceGroupName $strresourceGroupName -Name $storageAccountName) | where KeyName -eq 'key1').value
$storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$startTime = (get-date).AddMinutes(-15).ToUniversalTime()
$expiryTime = (get-date).AddDays(7).ToUniversalTime()
$storageAccountSasToken = New-AzureStorageAccountSASToken -Service Blob,Table -ResourceType Container,Object -Permission 'wlacu' -Protocol HttpsOnly -Context $storageContext -StartTime $startTime -ExpiryTime $expiryTime
$protectedSettingString = ('{"storageAccountName": "' + $storageAccountName + '","storageAccountSasToken": "' + $storageAccountSasToken.Remove(0,1) + '"}')


# Get latest LAD version number
$publisher = 'Microsoft.Azure.Diagnostics'
$extensionType = 'LinuxDiagnostic'
$extensionName = $extensionType
$extension = get-azurermvmextensionimage -Location $location -PublisherName $publisher -Type $extensionType
$version = $extension[-1].Version
$version = ($version.Split('.')[0] + '.' + $version.Split('.')[1])

# Remove existing version of LAD - IF ANY
remove-AzureRmVMExtension -ResourceGroupName $vmresourceGroupName -VMName $vmName -Name $extensionName -force

# Use lad_2_3_compatible_portal_pub_settings.json as starting point for settings
$webClient = New-Object System.Net.WebClient
$url = 'https://raw.githubusercontent.com/Azure/azure-linux-extensions/master/Diagnostic/tests/lad_2_3_compatible_portal_pub_settings.json'
$fileName = $url.Split('/')[-1]
$filePath = "$pwd\$fileName"
$webclient.DownloadFile($url,$filepath)
$settings = get-content $filePath | convertfrom-json

# Update settings with VM's diag storage account and resourceId
$settings.StorageAccount = $storageAccountName
$settings.ladcfg.diagnosticMonitorConfiguration.metrics.resourceid = $vm.id
$settingString = $settings | ConvertTo-Json -Depth 100

# Add LAD
set-AzureRmVMExtension -ResourceGroupName $vmresourceGroupName -VMName $vmName -Location $location -Name $extensionName -Publisher $publisher -ExtensionType $extensionType -TypeHandlerVersion $version -SettingString $settingString -ProtectedSettingString $protectedSettingString