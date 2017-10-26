# Powershell scripts

## ImportExportStorageTable
Contains functions to:
+ export the rows of a storage account to a csv
+ import the rows of a csv into a storage account

You can run this as part of you VSTS release cycle, by adding it to the release definition.
When looking for 'Powershell' tasks in VSTS, you'll find a couple but the 'Azure PowerShell' task from Microsoft has a limit on 500 characters. It's better to use the Xpirit one by Peter Groenewegen called 'Run Inline Azure Powershell'.
