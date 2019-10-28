$ResourceGroupName = "xxxx" #リソースグループ名
$VmName = "xxxx" #仮想マシン名
$BackupVhdUri = "https://xxxx.blob.core.windows.net/xxx/xxxx.vhd" #VHDファイルのパス

# Login
Connect-AzAccount
$mySub = Get-AzSubscription | Out-GridView -Title "Select an Azure Subscription ..." -PassThru
Select-AzSubscription -SubscriptionId $mySub.Id

$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName
$Vm.StorageProfile.OsDisk.Vhd.Uri = $BackupVhdUri　#交換用ディスクのパス
Update-AzVM -ResourceGroupName $ResourceGroupName -VM $Vm