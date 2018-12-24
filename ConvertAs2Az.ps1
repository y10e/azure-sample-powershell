#注意事項
# 管理ディスク仮想マシンを対象に可用性ゾーン仮想マシンに変換する
# 元の仮想マシンは削除される
# 元の仮想マシンに関連するリソース（ディスク）は残るので必要に応じて削除する

#ログイン
Login-AzureRmAccount

#サブスクリプションを選択
$srcSub = Get-AzureRmSubscription | Out-GridView -Title "Select Your Subscription ..." -PassThru
Select-AzureRmSubscription  $srcSub.SubscriptionId

#仮想マシンを選択
$trgVM  = Get-AzureRmVM | Out-GridView -Title "Select Your Virtual Machine  ..." -PassThru
$location = $trgVM.Location
$ResourceGroup = $trgVM.ResourceGroupName

#リージョン、サイズに応じた Availability Zone を選択
$aznum = (Get-AzureRmComputeResourceSku | where {$_.Locations.Contains("$($location)")} | where {$_.Name.Contains("$($trgVM.HardwareProfile.VmSize)")}).LocationInfo.Zones | Out-GridView -Title "Select a AvailabilityZone ..." -PassThru  

#事前処理
$trgVM | Stop-AzureRmVM -Force #仮想マシンの停止
$trgVM | Remove-AzureRmVM  #仮想マシンを削除

#OSディスクのスナップショットを取得
$srcDisk =  Get-AzureRmResource -ResourceId  $trgVM.StorageProfile.OsDisk.ManagedDisk.Id
$snapshotConfig =  New-AzureRmSnapshotConfig -SourceUri $srcDisk.ResourceId -CreateOption Copy -Location $location
$snapshot = New-AzureRmSnapshot -Snapshot $snapshotConfig -SnapshotName "$($srcDisk.Name)_snapshot" -ResourceGroupName $ResourceGroup

#スナップショットから可用性ゾーン管理ディスクを作成
$config = New-AzureRmDiskConfig -CreateOption Copy -SourceResourceId $snapshot.Id -Location $location  -OsType $srcDisk.Properties.osType -Zone $aznum
$osDisk = New-AzureRmDisk -ResourceGroupName $ResourceGroup -DiskName "$($srcDisk.Name)_az" -Disk $config

#ネットワークリソースの作成
$srcNICi =  Get-AzureRmResource -ResourceId  $trgVM.NetworkProfile.NetworkInterfaces.Id
$srcNIC = Get-AzureRmNetworkInterface -ResourceGroupName $srcNICi.ResourceGroupName -Name $srcNICi.Name

#Standard パブリックIPアドレス（IPアドレスのSKUは変更できないため再作成）
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup -Location $location -Zone $aznum -AllocationMethod Static -IdleTimeoutInMinutes 4 -Name "newstandardPip"
$srcNIC.IpConfigurations | ForEach-Object { $_.PublicIpAddress = $null }
$srcNIC.IpConfigurations[-1].PublicIpAddress = $pip
Set-AzureRmNetworkInterface -NetworkInterface $srcNIC


#変換した可用性ゾーンの管理ディスクより仮想マシンの作成
$vmConfig = New-AzureRmVMConfig -VMName "$($trgVM.Name)Az" -VMSize "$($trgVM.HardwareProfile.VmSize)" -Zone $aznum  | Add-AzureRmVMNetworkInterface -Id $srcNIC.Id
if($osDisk.OsType -eq "Windows"){
    Set-AzureRmVMOSDisk -VM $vmConfig -Name $osDisk.Name -CreateOption "Attach" -ManagedDiskId $osDisk.Id -Windows
}else{
    Set-AzureRmVMOSDisk -VM $vmConfig -Name $osDisk.Name -CreateOption "Attach" -ManagedDiskId $osDisk.Id -Linux
}
New-AzureRmVM -ResourceGroupName $ResourceGroup -Location $location -VM $vmConfig #-AsJob