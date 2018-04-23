Param (
    # Input parameters
    [Parameter (Mandatory = $true)]
    [string] 
    $RunbookName,
 
    [Parameter (Mandatory = $true)]
    [string] 
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
$Message.Subject = "Runbook job: $($RunbookName)"
         
# Set email body
$Message.Body = "Runbook message: <br /><br /> $($MessageBody)"
$Message.BodyEncoding = ([System.Text.Encoding]::UTF8)
$Message.IsBodyHtml = $true
         
# Create and set SMTP
$SmtpClient = New-Object System.Net.Mail.SmtpClient 'smtp.office365.com', 587
$SmtpClient.Credentials = $O365Credential
$SmtpClient.EnableSsl   = $true
   
# Send email message
$SmtpClient.Send($Message)