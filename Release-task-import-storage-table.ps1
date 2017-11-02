# Arguments -> Output of "Create SAS Token" task
# -_artifactsLocation "$(storageUriPowershellContainer)" -_artifactsLocationSasToken "$(storageTokenPowershellContainer)"


# Powershell -> Inline for "Run Inline Azure Powershell" task
Param([string]$_artifactsLocation , [string]$_artifactsLocationSasToken)

###########################################################################
# Variables needed to find the storage table to import into
###########################################################################
$AzureRmSubscriptionName = (Get-AzureRmContext).Subscription.SubscriptionName
$AzureResourceGroupName = "rg-name"
$AzureStorageAccountName = "saname"
$AzureStorageTableName = "sa-table-name"
$PathToCsv = "$(System.DefaultWorkingDirectory)/artifactlocation-from-build/storagetablecontent/test.csv"

###########################################################################
# Download the Powershell module containing the import function (must be downloaded as Import-Module is expecting the module on disk!)
###########################################################################
$PowershellModule = "Import-export-storage-table-module.psm1"
$urlPowershellModule = "$_artifactsLocation/$PowershellModule" + "$_artifactsLocationSasToken"
$dlpathPowershellModule = "$Env:SYSTEM_DEFAULTWORKINGDIRECTORY\Import-export-storage-table-module.psm1"
(New-Object System.Net.WebClient).DownloadFile($urlPowershellModule, $dlpathPowershellModule)

Import-Module -Name $dlpathPowershellModule

Select-AzureRmSubscription -SubscriptionName $AzureRmSubscriptionName
Import-AzureTableStorage -ResourceGroupName $AzureResourceGroupName -StorageAccountName $AzureStorageAccountName -TableName $AzureStorageTableName -Path $PathToCsv
