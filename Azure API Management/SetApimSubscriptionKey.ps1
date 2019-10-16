param
(
    [string] $resourceGroupName,
    [string] $apimServiceName,
    [string] $userEmail,
    [string] $subscriptionKey
)

# Install package provider to be able to install modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force

# Allow cmdlets for APIM to be used
Install-Module -Name Az.ApiManagement -AllowClobber -Scope CurrentUser -force

# Get reference to APIM instance
$apimContext = New-AzureRmApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $apimServiceName

# Find the user Id based on the email
$user = Get-AzureRmApiManagementUser -Context $apimContext -Email $userEmail

# Retrieve the subscriptions to modify
$subscription = Get-AzureRmApiManagementSubscription -Context $apimContext -UserId $user.UserId

# Set subscription key on the first subscription (probably will be only one)
Set-AzureRmApiManagementSubscription -Context $apimContext -SubscriptionId $subscription[0].SubscriptionId -PrimaryKey $subscriptionKey
