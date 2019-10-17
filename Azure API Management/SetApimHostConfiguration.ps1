#--------------------------------------------------------------
# Script to setup custom proxy host configuration on APIM
#--------------------------------------------------------------
param
(
    [string] $resourceGroupName,
    [string] $apimServiceName,
    [string] $apiProxyHostname,
    [string] $kvCertificateSecret
)

# Allow cmdlets to be used
Install-Module -Name Az.ApiManagement -AllowClobber -Scope CurrentUser -force

# Create the HostnameConfiguration object for Proxy endpoint
$proxyConfiguration = New-AzApiManagementCustomHostnameConfiguration -Hostname $apiProxyHostname -HostnameType Proxy -KeyVaultId $kvCertificateSecret

# Get reference to APIM instance and apply the configuration to API Management
$apimContext = Get-AzApiManagement -ResourceGroupName $resourceGroupName -Name $apimServiceName
$apimContext.ProxyCustomHostnameConfiguration = $proxyConfiguration 
Set-AzApiManagement -InputObject $apimContext
