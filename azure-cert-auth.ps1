Login-AzureRmAccount

$certName = "jegebhScriptCert"
$servicePrincipalName = "jegebhSvcPrncpl"
$localCertLocation = "cert:\LocalMachine\My"

#Create a certificate and create the service principal 
$cert = New-SelfSignedCertificate -CertStoreLocation $localCertLocation -Subject "CN=$($certName)" -KeySpec KeyExchange 
$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())
$sp = New-AzureRMADServicePrincipal -DisplayName $servicePrincipalName -CertValue $keyValue -EndDate $cert.NotAfter -StartDate $cert.NotBefore

New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ApplicationId $sp.ApplicationId

#Authenticate using the certificate
$TenantID = ""
$AppID = ""
$Thumbprint = (Get-ChildItem cert:\CurrentUser\My\ | Where-Object {$_.Subject -match "CN=$($certName)" }).Thumbprint 

Login-AzureRmAccount -ServicePrincipal -CertificateThumbprint $Thumbprint -ApplicationId $AppId -TenantId $TenantId
