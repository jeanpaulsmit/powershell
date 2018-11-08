# Powershell scripts

## Generate-SAS-token script
Script to generate a SAS token for a blob storage container, and downloads a blob from that container to disk.

## Import-export-storage-table-module
Contains functions to:
+ export the rows of a storage table to a csv
+ import the rows of a csv into a storage table

## Import-export-storage-table script
Uses the module above to perform the import or export of storage table data

## Release-taks-import-storage-table script
This script can be used in a build/release definition to download the import/export Powershell module and execute the storage table refresh.
It depends on parameters containing the Powershell module in blob storage and a SAS token to allow access to it.
The SAS token can be created using the [Create SAS Token](https://marketplace.visualstudio.com/items?itemName=pascalnaber.PascalNaber-Xpirit-CreateSasToken#review-details) task by Pascal Naber, the output can be used as parameters for the next task which executes the Powershell script: [Run Inline Azure Powershell](https://marketplace.visualstudio.com/items?itemName=petergroenewegen.PeterGroenewegen-Xpirit-Vsts-Build-InlinePowershell) by Peter Groenewegen (which hasn't got a character limitation like the Microsoft one has).

## Get Application Insights details (to find instance when having a key)
```
Get-AzureRmResource -ExpandProperties -ResourceType "microsoft.insights/components"  -ResourceGroupName "your-resource-group" | select -ExpandProperty Properties  | Select Name, InstrumentationKey
```
```
Get-AzureRmResource -ExpandProperties -ResourceType "microsoft.insights/components" | select -ExpandProperty Properties  | Select Name, InstrumentationKey
```
