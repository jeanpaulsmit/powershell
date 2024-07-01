# Retrieve all failed logic app runs between the specified dates
$resourceGroupName="My-Resource-Group"
$logicAppName="my-logic-app"
$startDate = Get-Date "June 24 2024 1:00 PM" # keep in mind the run time is stored and queried in UTC!
$endDate = Get-Date "June 26 2024 12:00 PM" # keep in mind the run time is stored and queried in UTC!
$subscriptionId = "my-subscription-id"
Connect-AzAccount -TenantId "my-tenant-id"
Set-AzContext -Subscription $subscriptionId


$failedRuns = Get-AzLogicAppRunHistory -ResourceGroupName $resourceGroupName -Name $logicAppName -FollowNextPageLink | 
                Where-Object { $_.Status -eq 'Failed' -and $_.StartTime -ge $startDate -and $_.StartTime -le $endDate }

Write-Host "Number of failed runs: $($failedRuns.Count)"            

$token = "my-generated-jwt-token"
$headers = @{
	'Authorization' = 'Bearer ' + $token
}

# Display the list of failed runs
foreach ($run in $failedRuns) {

    Write-Host "Resubmitting logic app with start Time: $($run.StartTime) - $($run.Name)"

    $uri = 'https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Logic/workflows/{2}/triggers/{3}/histories/{4}/resubmit?api-version=2016-06-01' -f $subscriptionId, $resourceGroupName, $logicAppName, $run.Trigger.Name, $run.Name
	Invoke-RestMethod -Method 'POST' -Uri $uri -Headers $headers
	
	write-host "+1"
	start-sleep -Milliseconds 100
}
