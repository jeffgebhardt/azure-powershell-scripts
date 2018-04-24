Param (
    # Input parameters
    [Parameter (Mandatory = $true)]
    [string] 
    $RunbookName,
 
    [Parameter (Mandatory = $true)]
    [object] 
    $MessageBody
  )
 
# RetrieveOffice 365 credential from Azure Automation Credentials
$O365Credential = Get-AutomationPSCredential -Name "mailCred"
     
# Create new MailMessage
$Message = New-Object System.Net.Mail.MailMessage
         
# Set address-properties
$Message.From = "v-jegebh@microsoft.com"
$Message.replyTo = "v-jegebh@microsoft.com"
$Message.To.Add("v-jegebh@microsoft.com")
   
# Set email subject
$Message.SubjectEncoding = ([System.Text.Encoding]::UTF8)
$Message.Subject = "Runbook job: $($RunbookName) | Deployment state: $($MessageBody.ProvisioningState)"
         
# Set email body
$Message.Body = "ARM Template Name: $($MessageBody.DeploymentName) `
                 <br /> Deployment state: $($MessageBody.ProvisioningState) `
                 <br /> Resource Group: $($MesssageBody.ResourceGroupName) `
                 <br /> CorrelationId: $($MesssageBody.CorrelationId) `
                 <br /> Deployment time: $($MessageBody.TimeStamp) `
                 <br /> Outputs: $($MessageBody.OutputsString) "
$Message.BodyEncoding = ([System.Text.Encoding]::UTF8)
$Message.IsBodyHtml = $true
         
# Create and set SMTP
$SmtpClient = New-Object System.Net.Mail.SmtpClient 'smtp.office365.com', 587
$SmtpClient.Credentials = $O365Credential
$SmtpClient.EnableSsl   = $true
   
# Send email message
$SmtpClient.Send($Message)