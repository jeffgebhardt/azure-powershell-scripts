param (
    [Parameter(Mandatory=$true)]
    [string]
    $DscConfigName
)

# Authenticate to Azure if running from Azure Automation
$ServicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $ServicePrincipalConnection.TenantId `
    -ApplicationId $ServicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint | Write-Verbose

$CompilationJob = Start-AzureRmAutomationDscCompilationJob -ResourceGroupName "jobivens-rg" -AutomationAccountName "automata" -ConfigurationName $DscConfigName

while($CompilationJob.EndTime –eq $null -and $CompilationJob.Exception –eq $null)
{
    $CompilationJob = $CompilationJob | Get-AzureRmAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}

$mailParams = @{
"RunbookName" = "deployConfigDSC";
"MessageBody" = $CompilationJob
}

Start-AzureRmAutomationRunbook -ResourceGroupName "jobivens-rg" -Name "sendMail" -AutomationAccountName "automata" -Parameters $mailParams