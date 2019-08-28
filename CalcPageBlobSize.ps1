# 設定項目
$subscriptionId = "xxxx-xxx-xxxx-xxxx-xxxxx" 
$RG = "<ResourceGroup>"
$StorageAccountName = "<Storage AccountName>"
$ContainerName ="<ContainerName>" 
$BlobName ="<PageBlobName>"

#ログインとサブスクリプションの選択
Login-AzAccount
Select-AzSubscription -Subscription $subscriptionId

<#
.SYNOPSIS
    Calculates cost of all blobs in a container or storage account. 
.DESCRIPTION
    Enumerates all blobs in either one container or one storage account and sums
    up all costs associated.  This includes all block and page blobs, all metadata
    on either blobs or containers.  It also includes both committed and uncommitted
    blocks in the case that a blob is partially uploaded.
 
    The details of the calculations can be found in this post:
    http://blogs.msdn.com/b/windowsazurestorage/archive/2010/07/09/understanding-windows-azure-storage-billing-bandwidth-transactions-and-capacity.aspx
 
    Note: This script requires an Azure Storage Account to run.  The storage account 
    can be specified by setting the subscription configuration.  For example:
    Set-AzureSubscription -SubscriptionName "MySubscription" -CurrentStorageAccount "MyStorageAccount"
.EXAMPLE
    .\CalculateBlobCost.ps1 -StorageAccountName "mystorageaccountname"
    .\CalculateBlobCost.ps1 -StorageAccountName "mystorageaccountname" -ContainerName "mycontainername"
#>
 
#param
(
     # The name of the storage account to enumerate.
    #[Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
 
   # The name of the storage container to enumerate.
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ContainerName
)
 
# Following modifies the Write-Verbose behavior to turn the messages on globally for this session
$VerbosePreference = "Continue"
 
# Check if Windows Azure Powershell is avaiable
if ((Get-Module -ListAvailable Azure) -eq $null)
{
    throw "Windows Azure Powershell not found! Please install from http://www.windowsazure.com/en-us/downloads/#cmd-line-tools"
}

<#
.SYNOPSIS
   Gets the size (in bytes) of a blob.
.DESCRIPTION
   Given a blob name, sum up all bytes consumed including the blob itself and any metadata,
   all committed blocks and uncommitted blocks.

   Formula reference for calculating size of blob:
       http://blogs.msdn.com/b/windowsazurestorage/archive/2010/07/09/understanding-windows-azure-storage-billing-bandwidth-transactions-and-capacity.aspx
.INPUTS
   $Blob - The blob to calculate the size of.
.OUTPUTS
   $blobSizeInBytes - The calculated sizeo of the blob.
#>
function Get-BlobBytes
{
    param (
        [Parameter(Mandatory=$true)]
        [Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageBlob]$Blob)

 
    # Base + blob name
    $blobSizeInBytes = 124 + $Blob.Name.Length * 2
 
    # Get size of metadata
    $metadataEnumerator = $Blob.ICloudBlob.Metadata.GetEnumerator()
    while ($metadataEnumerator.MoveNext())
    {
        $blobSizeInBytes += 3 + $metadataEnumerator.Current.Key.Length + $metadataEnumerator.Current.Value.Length
    }
 
    if ($Blob.BlobType -eq [Microsoft.WindowsAzure.Storage.Blob.BlobType]::BlockBlob)
    {
        $blobSizeInBytes += 8
        $Blob.ICloudBlob.DownloadBlockList() | 
            ForEach-Object { $blobSizeInBytes += $_.Length + $_.Name.Length }
    }
    else
    {
        $Blob.ICloudBlob.GetPageRanges() | 
            ForEach-Object { $blobSizeInBytes += 12 + $_.EndOffset - $_.StartOffset }
    }

    return $blobSizeInBytes
}

#ストレージアカウントの取得
$storageAccount = Get-AzStorageAccount -StorageAccountName $StorageAccountName -ResourceGroupName $RG -ErrorAction SilentlyContinue
if ($storageAccount -eq $null)
{
    throw "The storage account specified does not exist in this subscription."
}
$storagePrimaryKey = (Get-AzStorageAccountKey -StorageAccountName $StorageAccountName -ResourceGroupName $RG)[0].Value

#コンテナの取得
$container =Get-AzRmStorageContainer -StorageAccountName $StorageAccountName -Name $ContainerName -ResourceGroupName $RG -ErrorAction SilentlyContinue
if ($container -eq $null)
{
    throw "The storage container specified does not exist in this storage account."
}

#BLOBの取得
$blob = Get-AzStorageBlob -Context $storageContext -Container $Container.Name -Blob $BlobName
if ($blob -eq $null)
{
    throw "The blob file specified does not exist in this container."
}

#サイズ計算
$blobSize = Get-BlobBytes -Blob $blob
Write-Host $($blob.Name)$($blobSize / ([Math]::Pow(1023, 3)))"GB"  #GB計算