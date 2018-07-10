$cert = New-SelfSignedCertificate -certstorelocation 'cert:\localmachine\my' -dnsname 'testcert.didago.nl' -NotBefore "2018-01-01 00:00:00z"
$pwd = ConvertTo-SecureString -String 'passw0rd!' -Force -AsPlainText

$path = 'cert:\localMachine\my\' + $cert.thumbprint 
Export-PfxCertificate -cert $path -FilePath '.\cert.pfx' -Password $pwd
