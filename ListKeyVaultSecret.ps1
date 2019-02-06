function FormatObject ($obj)
{
    $p = new-object PSObject
    $p | Add-Member -Name VaultName -TypeName string -Value $obj.VaultName  -MemberType NoteProperty 
    $p | Add-Member -Name Name -TypeName string -Value $obj.Name  -MemberType NoteProperty 
    $p | Add-Member -Name Created -TypeName string -Value $obj.Created  -MemberType NoteProperty 
    $p | Add-Member -Name MachineName -TypeName string -Value $obj.Tags.MachineName  -MemberType NoteProperty 
    $p | Add-Member -Name VolumeLetter -TypeName string -Value $obj.Tags.VolumeLetter  -MemberType NoteProperty
    return $p
}

#ログインとサブスクリプションの選択
Login-AzureRmAccount
$mySub = Get-AzureRmSubscription | Out-GridView -Title "Select an Azure Subscription ..." -PassThru
Select-AzureRmSubscription -SubscriptionId $mySub.Id

#パラメータ
$KeyVaultName = Get-AzureRmKeyVault | Out-GridView -Title "Select an KeyVault ..." -PassThru
$secrets = Get-AzureKeyVaultSecret -VaultName $KeyVaultName.VaultName

[Object]$displayObj  = @()
foreach($s in $secrets)
{
   $displayObj += FormatObject($s)
}

#結果表示
$displayObj | select | Format-Table