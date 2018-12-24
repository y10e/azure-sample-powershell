#ログイン
Login-AzureRmAccount

#サブスクリプションを選択
$srcSub = Get-AzureRmSubscription | Out-GridView -Title "Select Your Subscription ..." -PassThru
Select-AzureRmSubscription  $srcSub.SubscriptionId
