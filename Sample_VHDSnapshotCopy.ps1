############
# 免責事項 #
############
# 本サンプルスクリプトは、サンプルとして提供されるものであり、
# 製品の実運用環境で使用されることを前提に提供されるものでは
# ありません。
#
# 本サンプルコードおよびそれに関連するあらゆる情報は、「現状
# のまま」で提供されるものであり、商品性や特定の目的への適合性
# に関する黙示の保証も含め、明示・黙示を問わずいかなる保証も付
# されるものではありません。
#
# マイクロソフトは、お客様に対し、本サンプルコードを使用および
# 改変するための
# 非排他的かつ無償の権利ならびに本サンプルコードをオブジェクト
# コードの形式で
# 複製および頒布するための非排他的かつ無償の権利を許諾します。
#
# 但し、お客様は、（１）本サンプルコードが組み込まれたお客様の
# ソフトウェア製品のマーケティングのためにマイクロソフトの会社
# 名、ロゴまたは、商標を用いないこと、（２）本サンプルコードが
# 組み込まれたお客様のソフトウェア製品に有効な著作権表示をする
# こと、および（３）本サンプルコードの使用または頒布から生じる
# あらゆる 損害（弁護士費用を含む）に関する請求または訴訟につ
# いて、マイクロソフトおよびマイクロソフトの取引業者に対し補償
# し、損害を与えないことに同意するものとします。

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