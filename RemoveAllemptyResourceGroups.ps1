$resourceGroups = Get-AzureRmResourceGroup
foreach ($rg in $resourceGroups)
{
    $resources = Get-AzureRmResource -ResourceGroupName $rg.ResourceGroupName

    if($resources.count -le 0)
    {
        Remove-AzureRmResourceGroup -Name $rg.ResourceGroupName -AsJob
    }
}