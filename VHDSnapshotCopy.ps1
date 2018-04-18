# パラメータ
$SourceStorageAccountName = "xxxxxx" #コピー元ストレージアカウント名
$SourceContainerName = "vhds" #コピー元コンテナー名
$SourceBlobName = "xxxxxx.vhd" #コピー元 VHD ファイル名
$SourceStorageAccountKey = "xxxxxx" #コピー元ストレージアカウントキー

$DestStorageAccountName = "xxxxxx" #コピー先ストレージアカウント名
$DestContainerName = "vhds" #コピー先コンテナー名
$DestBlobName = "xxxxxx.vhd" #コピー先 VHD ファイル名
$DestStorageAccountKey = "xxxxxx" #コピー先ストレージアカウントキー

# VHD ファイルのスナップショット取得(コピー)実施
$Ctx = New-AzureStorageContext -StorageAccountName $SourceStorageAccountName -StorageAccountKey $SourceStorageAccountKey
$blob = Get-AzureStorageBlob -Context $Ctx -Container $SourceContainerName -Blob $SourceBlobName
$snap = $blob.ICloudBlob.CreateSnapshot()
$DestContext = New-AzureStorageContext -StorageAccountName $DestStorageAccountName -StorageAccountKey $DestStorageAccountKey
Start-AzureStorageBlobCopy -SrcUri $snap.SnapshotQualifiedUri -SrcContext $Ctx -DestContext $DestContext -DestContainer $DestContainerName -DestBlob $DestBlobName