function invoke-dirsync () {
<#
.Synopsis
Triggers Synchronisation between Active Directory on-site and Azure Active Directory

.Description
Triggers a scheduled task that is running on Dirsync which in turn starts Dirsync synchronisation. 

.Parameters Credentials
For future use possibly credentials to access remote computer

.example
invoke-dirsync 

.notes
Has to be a better way to do this but it does not seem that PPDirsynch has required modules to trigger synchronisation via powershell

#>



[CmdletBinding()] param(

)


$session = New-PSSession -ComputerName dirsync -Authentication Kerberos
$scriptblock = {get-scheduledtask -taskname *azure* | start-scheduledtask}
Invoke-Command -Session $session -ScriptBlock $scriptblock

}