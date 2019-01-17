$StorageAccountName = "xxxx" #ストレージアカウント名
$StorageAccountKey = "xxxxx" #ストレージアカウントキー
 

#スナップショット一覧
$Ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$blobs = Get-AzureStorageContainer -Context $Ctx |  Get-AzureStorageBlob -Context $Ctx
$ListSnapshot = $blobs | Where-Object {$_.ICloudBlob.IsSnapshot -and $_.SnapshotTime -ne $null }
$ListSnapshot | select Name, SnapshotTime