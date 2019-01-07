# パラメータ
$StorageAccountName = "xxxx" #コピー元ストレージアカウント名
$ContainerName = "xxxx" #コピー元コンテナー名
$BlobName = "xxxx" #コピー元 VHD ファイル名
$StorageAccountKey = "xxxx" #コピー元ストレージアカウントキー
 

# ファイルのスナップショット一覧
$Ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$blob = Get-AzureStorageBlob -Context $Ctx -Container $ContainerName -Blob $BlobName
$ListBlob = Get-AzureStorageBlob –Context $Ctx -Prefix $BlobName -Container $ContainerName | Where-Object {$_.ICloudBlob.IsSnapshot -and $_.Name -eq $BlobName -and $_.SnapshotTime -ne $null }
$ListBlob