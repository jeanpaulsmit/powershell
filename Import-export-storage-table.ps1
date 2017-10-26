$AzureRmSubscriptionName = (Get-AzureRmContext).Subscription.SubscriptionName
$AzureResourceGroupName = "rg-name"
$AzureStorageAccountName = "saname"
$AzureStorageTableName = "sa-table-name"
$PathToCsv = "D:\Source\Github\Test\Test.csv"

Import-Module -Name "D:\Source\Github\jeanpaulsmit-powershell\Import-export-storage-table-module.psm1"

Select-AzureRmSubscription -SubscriptionName $AzureRmSubscriptionName
#Export-AzureTableStorage -ResourceGroupName $AzureResourceGroupName -StorageAccountName $AzureStorageAccountName -TableName $AzureStorageTableName -Path "D:\Source\Github\Test"
Import-AzureTableStorage -ResourceGroupName $AzureResourceGroupName -StorageAccountName $AzureStorageAccountName -TableName $AzureStorageTableName -Path $PathToCsv
