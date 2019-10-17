#--------------------------------------------------------------------------
# Script to set a custom subscription key on APIM subscriptions
# Used to align subscription keys across APIM regions (with standard tier)
#--------------------------------------------------------------------------
param
(
    [string] $resourceGroupName,
    [string] $apimServiceName,
    [string] $productId,
    [string] $userId,
    [string] $subscriptionKey
)

# Allow cmdlets for APIM to be used
Install-Module -Name Az.ApiManagement -AllowClobber -Scope CurrentUser -force

# Get reference to APIM instance
$apimContext = New-AzApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $apimServiceName

# Retrieve the subscription to modify
$subscription = Get-AzApiManagementSubscription -Context $apimContext -ProductId $productId -UserId $userId

# Set custom subscription key
Set-AzApiManagementSubscription -Context $apimContext -SubscriptionId $subscription.SubscriptionId -PrimaryKey $subscriptionKey -SecondaryKey $subscription.SecondaryKey -State $subscription.State
