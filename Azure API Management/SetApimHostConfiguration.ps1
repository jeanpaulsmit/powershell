param
(
    [string] $resourceGroupName,
    [string] $apimServiceName,
    [string] $apiProxyHostname,
    [string] $pfxCertificateLocation,
    [string] $pfxCertificatePwd
)

# Install package provider to be able to install modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force

# Allow cmdlets for APIM to be used
Install-Module -Name Az.ApiManagement -AllowClobber -Scope CurrentUser -force

# Create the HostnameConfiguration object for Proxy endpoint
$securePassword = ConvertTo-SecureString -String $pfxCertificatePwd -AsPlainText -Force
$proxyConfiguration = New-AzApiManagementCustomHostnameConfiguration -Hostname $apiProxyHostname -HostnameType Proxy -PfxPath $pfxCertificateLocation -PfxPassword $securePassword

# Get reference to APIM instance and apply the configuration to API Management
$apimContext = Get-AzApiManagement -ResourceGroupName $resourceGroupName -Name $apimServiceName
$apimContext.ProxyCustomHostnameConfiguration = $proxyConfiguration 
Set-AzApiManagement -InputObject $apimContext
