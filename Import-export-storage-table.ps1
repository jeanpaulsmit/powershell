$AzureRmSubscriptionName = (Get-AzureRmContext).Subscription.SubscriptionName
$AzureResourceGroupName = "rg-name"
$AzureStorageAccountName = "saname"
$AzureStorageTableName = "sa-table-name"
$PathToCsv = "D:\Source\Github\Test\Test.csv"

Function Import-AzureTableStorage
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param
    (
        [Parameter(Mandatory=$true)] [String]$ResourceGroupName,
        [Parameter(Mandatory=$true)] [String]$StorageAccountName,
        [Parameter(Mandatory=$true)] [String]$TableName,
        [Parameter(Mandatory=$true)] [String]$Path
    )

    #Check if Windows Azure PowerShell Module is avaliable
    If((Get-Module -ListAvailable Azure) -eq $null)
    {
        Write-Warning "Windows Azure PowerShell module not found! Please install from http://www.windowsazure.com/en-us/downloads/#cmd-line-tools"
    }
    Else
    {
        If($StorageAccountName)
        {
            Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -ErrorAction SilentlyContinue -ErrorVariable IsExistStorageError | Out-Null

            #Check if storage account is exist
            If($IsExistStorageError.Exception -eq $null)
            {
                If($TableName)
                {
                    #Specify a Windows Azure Storage Library path
                    $StorageLibraryPath = "$env:SystemDrive\Program Files\Microsoft SDKs\Azure\.NET SDK\v2.8\toolsref\Microsoft.WindowsAzure.Storage.dll"

                    #Getting Azure storage account key
                    $Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName
                    $StorageAccountKey = $Keys[0].Value

                    #Loading Windows Azure Storage Library for .NET.
                    Write-Verbose -Message "Loading Windows Azure Storage Library from $StorageLibraryPath"
                    [Reflection.Assembly]::LoadFile("$StorageLibraryPath") | Out-Null

                    $Creds = New-Object Microsoft.WindowsAzure.Storage.Auth.StorageCredentials("$StorageAccountName","$StorageAccountKey")
                    $CloudStorageAccount = New-Object Microsoft.WindowsAzure.Storage.CloudStorageAccount($Creds, $true)
                    $CloudTableClient = $CloudStorageAccount.CreateCloudTableClient()
                    $Table = $CloudTableClient.GetTableReference($TableName)

                    $Table.CreateIfNotExists()

                    If(Test-Path -Path $Path)
                    {
                        # Don't delete table because due to async behavior we cannot create it again right away, so we need to clean it
                        DeleteAllEntities($Table)

                        $CsvContents = Import-Csv -Path $Path
                        $CsvHeaders = ($CsvContents[0] | Get-Member -MemberType NoteProperty).Name | Where{$_ -ne "RowKey" -and $_ -ne "PartitionKey"}

                        Foreach($CsvContent in $CsvContents)
                        {
                            $PartitionKey = $CsvContent.PartitionKey
                            $RowKey = $CsvContent.RowKey
                            $Entity = New-Object "Microsoft.WindowsAzure.Storage.Table.DynamicTableEntity" "$PartitionKey", "$RowKey"

                            Foreach($CsvHeader in $CsvHeaders)
                            {
                                $Value = $CsvContent.$CsvHeader
                                $Entity.Properties.Add($CsvHeader, $Value)
                            }
                            Write-Verbose "Inserting the entity into table storage."
                            $result = $Table.Execute([Microsoft.WindowsAzure.Storage.Table.TableOperation]::Insert($Entity))
                        }
                        Write-Host "Successfully Imported entities of table storage named '$TableName'."
                    }
                    Else
                    {
                        Write-Warning "The path does not exist, please check it is correct."
                    }
                }
            }
            Else
            {
                Write-Warning "Cannot find storage account '$StorageAccountName' because it does not exist. Please make sure that the name of storage is correct. (error:$IsExistStorageError.Exception)"
            }
        }
    }
}

Function Export-AzureTableStorage
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param
    (
        [Parameter(Mandatory=$true)] [String]$ResourceGroupName,
        [Parameter(Mandatory=$true)] [String]$StorageAccountName,
        [Parameter(Mandatory=$true)] [String]$TableName,
        [Parameter(Mandatory=$true)] [String]$Path
    )

    #Check if Windows Azure PowerShell Module is avaliable
    If((Get-Module -ListAvailable Azure) -eq $null)
    {
        Write-Warning "Windows Azure PowerShell module not found! Please install from http://www.windowsazure.com/en-us/downloads/#cmd-line-tools"
    }
    Else
    {
        If($StorageAccountName)
        {
            Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -ErrorAction SilentlyContinue -ErrorVariable IsExistStorageError | Out-Null

            #Check if storage account is exist
            If($IsExistStorageError.Exception -eq $null)
            {
                If($TableName)
                {
                    #Getting Azure storage account key
                    $Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName
                    $StorageAccountKey = $Keys[0].Value

                    $context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
                    Get-AzureStorageTable -c $context -Name $TableName -ErrorAction SilentlyContinue -ErrorVariable IsExistTableError | Out-Null

                    #Check if table is exist
                    If($IsExistTableError.Exception -eq $null)
                    {
                        #Specify a Windows Azure Storage Library path
                        $StorageLibraryPath = "$env:SystemDrive\Program Files\Microsoft SDKs\Azure\.NET SDK\v2.8\toolsref\Microsoft.WindowsAzure.Storage.dll"

                        #Loading Windows Azure Storage Library for .NET.
                        Write-Verbose -Message "Loading Windows Azure Storage Library from $StorageLibraryPath"
                        [Reflection.Assembly]::LoadFile("$StorageLibraryPath") | Out-Null

                        $Creds = New-Object Microsoft.WindowsAzure.Storage.Auth.StorageCredentials("$StorageAccountName","$StorageAccountKey")
                        $CloudStorageAccount = New-Object Microsoft.WindowsAzure.Storage.CloudStorageAccount($Creds, $true)
                        $CloudTableClient = $CloudStorageAccount.CreateCloudTableClient()
                        $Table = $CloudTableClient.GetTableReference($TableName)

                        $Query = New-Object "Microsoft.WindowsAzure.Storage.Table.TableQuery"
                        $Datas = $Table.ExecuteQuery($Query)
                        
                        $ExportObjs = @()
                        
                        Foreach($Data in $Datas)
                        {
  
                           $Obj = New-Object PSObject

                           $Obj | Add-Member -Name PartitionKey -Value $Data.PartitionKey -MemberType NoteProperty
                           $Obj | Add-Member -Name RowKey -Value $Data.RowKey -MemberType NoteProperty 

                           $Data.Properties.Keys | Foreach{$Value = $data.Properties[$_].PropertyAsObject;
                           $Obj | Add-Member -Name $_ -Value $value -MemberType NoteProperty; }

                           $ExportObjs += $Obj
                        } 

                        #Export the entities of table storage to csv file. 
                        $ExportObjs | Export-Csv "$Path\$TableName.csv" -NoTypeInformation
                        Write-Host "Successfully export the table storage to csv file."

                    }
                    Else
                    {
                        Write-Warning "Cannot find blob '$TableName' because it does not exist. Please make sure thar the name of table is correct."
                    }
                }
            }
            Else
            {
                Write-Warning "Cannot find storage account '$StorageAccountName' because it does not exist. Please make sure thar the name of storage is correct."
            }
        }
    }
}

Function DeleteAllEntities($table)
{
    $Query = New-Object "Microsoft.WindowsAzure.Storage.Table.TableQuery" 
    $Entities = $table.ExecuteQuery($Query);
    $Entities|Foreach{
        $table.Execute([Microsoft.WindowsAzure.Storage.Table.TableOperation]::Delete($_))|Out-Null
    }
}

Select-AzureRmSubscription -SubscriptionName $AzureRmSubscriptionName
#Export-AzureTableStorage -ResourceGroupName $AzureResourceGroupName -StorageAccountName $AzureStorageAccountName -TableName $AzureStorageTableName -Path "D:\Source\Github\Test"
Import-AzureTableStorage -ResourceGroupName $AzureResourceGroupName -StorageAccountName $AzureStorageAccountName -TableName $AzureStorageTableName -Path $PathToCsv
