
#ログイン
Login-AzureRmAccount

#移行元サブスクリプションを選択
$srcSub = Get-AzureRmSubscription | Out-GridView -Title "Select Your Subscription ..." -PassThru
Select-AzureRmSubscription  $srcSub.SubscriptionId

#移行ディスクを選択
$srcDisk =  Get-AzureRmDisk | Out-GridView -Title "Select Your Managed Disk  ..." -PassThru
$snapshotConfig =  New-AzureRmSnapshotConfig -SourceUri $srcDisk.Id -CreateOption Copy -Location $srcDisk.Location
$snapshot = New-AzureRmSnapshot -Snapshot $snapshotConfig -SnapshotName "snapshot" -ResourceGroupName $srcDisk.ResourceGroupName 

#移行先サブスクリプションの選択
$dstSub = Get-AzureRmSubscription | Out-GridView -Title "Select Your Azure Subscription ..." -PassThru
Select-AzureRmSubscription  $dstSub.SubscriptionId
#移行先リソースグループの選択
$dstRg = Get-AzureRmResourceGroup | Out-GridView -Title "Select Your Resource Group ..." -PassThru
#ディスクを移行
$config = New-AzureRmDiskConfig -CreateOption Copy -SourceResourceId $snapshot.Id -Location $snapshot.Location  -OsType $srcDisk.OsType
New-AzureRmDisk -ResourceGroupName $dstRg.ResourceGroupName -DiskName $srcDisk.Name -Disk $config

#後始末
Select-AzureRmSubscription  $srcSub.SubscriptionId
$snapshot | Remove-AzureRmSnapshot -Force

