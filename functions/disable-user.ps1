
function disable-user {

<#
  .SYNOPSIS
  Disables users on the PP network
  .DESCRIPTION
  Disables user by converting mailbox to shared on O365, forwards emails to a forwarding address and then archives users  
  .EXAMPLE
  disable-user -identity olduser@contoso.com -forwardingaddress manager@contoso.com 
  .EXAMPLE
  disable-user -identity olduser@contoso.com -forwardingaddress manager@contoso.com -archiveou archivedusers
  .PARAMETER identity
  The username of the account to disable.
  .PARAMETER forwardingaddress
  The account to which mail needs to be forwarded to.
  .PARAMETER archiveou
  The organisational unit that the account needs to be put in
  #>
  
  [CmdletBinding()]
  param (
  [Parameter(Mandatory=$true,Position=1)]
  [string]$identity,
  [Parameter(Mandatory=$true)]
  [string]$forwardAddress,
  [string]$orgunit="ArchivedUsers"
  
  
  )


Import-Module activedirectory 
#connect to exchange-online
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
#connect to exchange-online
$cred = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $cred -Authentication Basic -AllowRedirection
$importCMD = Import-PSSession $session

#gets mailbox item size and converts it to an integer and checks if greater than 10Gb

$size = (get-mailboxstatistics -Identity $identity).TotalItemSize -replace "(.*\()|,| [a-z]*\)", ""
$size = [math]::Round($size/1GB,2)

if ($size -lt 10 ){

 set-Mailbox -identity $identity -type "Shared" 

#remove license, requires Azure AD ps module

Connect-MsolService -Credential $cred

$msolsku = (Get-MSOLUser -UserPrincipalName $identity).Licenses[0].AccountSkuId

Set-MsolUserLicense -UserPrincipalName $identity -RemoveLicenses $msolsku 

#Forward mail to:

set-mailbox -identity $identity -forwardingAddress $forwardAddress -DeliverToMailboxAndForward $false  

}

Else {

Write-Host "Mailbox is larger than 10Gb cannot convert to shared"

Break

}

#Collect User AD information

$disableduser=Get-ADUser -filter {emailaddress -eq $identity}

write-host "Reset user password" 

$disableduser | Set-ADAccountPassword 

#hide from address book and clear address book objects  

$disableduser| set-aduser -clear showinaddressbook -replace @{msexchhidefromaddresslists=$true} 

#move to archived orgunit

$disableduser | move-adobject -TargetPath (get-adorganizationalunit -filter {name -eq $orgunit})


 

 }






 

