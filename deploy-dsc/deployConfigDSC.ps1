param (
    [Parameter(Mandatory=$true)]
    [string]
    $ConfigFileName
)

# Authenticate to Azure if running from Azure Automation
$ServicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $ServicePrincipalConnection.TenantId `
    -ApplicationId $ServicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint | Write-Verbose

$StorageAccountKey = Get-AutomationVariable -Name 'storageKey'

# Create a new context
$Context = New-AzureStorageContext -StorageAccountName 'jegebhaastorage' -StorageAccountKey $StorageAccountKey

Get-AzureStorageFileContent -ShareName 'dsc-configs' -Context $Context -path $ConfigFileName -Destination 'C:\Temp'

$TemplatePath = Join-Path -Path 'C:\Temp' -ChildPath $ConfigFileName

$deployment = Import-AzureRmAutomationDscConfiguration -AutomationAccountName "automata" -ResourceGroupName "jobivens-rg" -SourcePath $TemplatePath -Published -Force

$mailParams = @{
"RunbookName" = "deployConfigDSC";
"MessageBody" = $deployment
}

Start-AzureRmAutomationRunbook -ResourceGroupName "jobivens-rg" -Name "sendMail" -AutomationAccountName "automata" -Parameters $mailParams