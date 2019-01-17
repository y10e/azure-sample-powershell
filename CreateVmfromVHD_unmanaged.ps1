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


#パラメータ
$SubscriptionId = "xxxxxx" #サブスクリプション ID
$VmName = "xxxxx" #仮想マシン名
$VmSize = "xxxx" #Standard_A1など
$VhdUri = "https://xxxx.blob.core.windows.net/vhds/xxxx.vhd" #VHD ファイルパス
$VnetName = "myvnet" #仮想ネットワーク名
$AddressPrefix = "192.168.1.0/25" #プレフィックス
$SubnetName = "mysubnetx" #サブネット名
$SubnetPrefix = "192.168.1.0/27" #プレフィックス
$ResourceGroupName = "xxxxx" #リソースグループ名
$Location = "xxx" #リージョン名(japanwestなど)
$NicName = "mynic" #NIC名
$PublicIpName = "mypip" #PublicIP名

# ログインとサブスクリプション指定
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $SubscriptionId

#仮想ネットワークの作成
$Vnet = New-AzureRmVirtualNetwork -Location $Location -Name $VnetName -ResourceGroupName $ResourceGroupName -AddressPrefix $AddressPrefix 
Add-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetPrefix -Name $SubnetName -VirtualNetwork $Vnet
Set-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetPrefix -Name $SubnetName -VirtualNetwork $Vnet
Set-AzureRmVirtualNetwork -VirtualNetwork $Vnet

# 仮想マシン設定の定義
$Vm = New-AzureRmVMConfig -Name $VmName -VMSize $VmSize
$Vm = Set-AzureRmVMOSDisk -VM $Vm -VhdUri $VhdUri -Name "OSDisk" -CreateOption attach -Windows -Caching ReadWrite

# 対象サブネット情報取得
$Subnet = (Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName).Subnets[0]

# NIC 新規作成
$Pip = New-AzureRmPublicIpAddress -Name $PublicIpName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic
$Nic = New-AzureRmNetworkInterface -Name $NicName -ResourceGroupName $ResourceGroupName -Location $Location -Subnet $Subnet -PublicIpAddress $Pip

# 作成した NIC を追加
$Nic = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $NicName
$Vm = Add-AzureRmVMNetworkInterface -VM $Vm -NetworkInterface $Nic
$Vm.NetworkProfile.NetworkInterfaces.Item(0).Primary = $true

# 仮想マシンの新規作成
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $Vm -Verbose