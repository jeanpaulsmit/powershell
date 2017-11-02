# Powershell scripts

## Generate-SAS-token
Script to generate a SAS token for a blob storage container, and downloads a blob from that container to disk.

## Import-export-storage-table-module
Contains functions to:
+ export the rows of a storage table to a csv
+ import the rows of a csv into a storage table

## Import-export-storage-table
Uses the module above to perform the import or export of storage table data

## Release-taks-import-storage-table
This script can be used in a release definition to download the import/export Powershell module and execute the storage table refresh.
It depends on parameters containing the Powershell module in blob storage and a SAS token to allow access to it.
The SAS token can be created using the 'Create SAS Token' task by Pascal Naber, the output can be used as parameters for the next task which executes the Powershell script: 'Run Inline Azure Powershell' by Peter Groenewegen (which hasn't got a character limitation like the Microsoft one has.
