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

# Allow cmdlets to be used
Install-Module -Name Az -AllowClobber -Scope CurrentUser -force

$subscriptionId = $env:ARM_SUBSCRIPTION_ID
$tenantId = $env:ARM_TENANT_ID
$clientId = $env:ARM_CLIENT_ID
$secret = $env:ARM_CLIENT_SECRET

$securesecret = ConvertTo-SecureString -String $secret -AsPlainText -Force
$Credential = New-Object pscredential($clientId,$securesecret)
Connect-AzAccount -Credential $Credential -Tenant $tenantId -ServicePrincipal
Select-AzSubscription $subscriptionId

# Get reference to APIM instance
$apimContext = New-AzApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $apimServiceName

# Retrieve the subscription to modify
$subscription = Get-AzApiManagementSubscription -Context $apimContext -ProductId $productId -UserId $userId

# Set custom subscription key
Set-AzApiManagementSubscription -Context $apimContext -SubscriptionId $subscription.SubscriptionId -PrimaryKey $subscriptionKey -SecondaryKey $subscription.SecondaryKey -State $subscription.State
