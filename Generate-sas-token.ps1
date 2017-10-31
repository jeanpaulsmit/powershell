
$AzureRmSubscriptionName = (Get-AzureRmContext).Subscription.SubscriptionName

Select-AzureRmSubscription -SubscriptionName "IM-DEV (Enterprise)" #$AzureRmSubscriptionName

$AzureResourceGroupName = "some-rg"
$AzureStorageAccountName = "somesa"
$AzureStorageContainerName = "somecontainer"

$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $AzureResourceGroupName -StorageAccountName $AzureStorageAccountName
$StorageAccountKey = $Keys[0].Value

$storageContext = New-AzureStorageContext -StorageAccountName $AzureStorageAccountName -StorageAccountKey $StorageAccountKey

$now=get-date
$sastoken = New-AzureStorageContainerSASToken -Name $AzureStorageContainerName -Context $storageContext -Permission rl -StartTime $now.AddHours(-1) -ExpiryTime $now.AddMonths(1)

$sastoken

$storageuri = "https://$AzureStorageAccountName.blob.core.windows.net/$AzureStorageContainerName"
$url = $storageUri + "/Import-export-storage-table-module.psm1" + $sastoken

$output = "d:/tmp/Import-export-storage-table-module.psm1"

(New-Object System.Net.WebClient).DownloadFile($url, $output)
