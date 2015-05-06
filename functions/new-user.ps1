function new-user {

<#
  .SYNOPSIS
  Creates new users on the PP network
  .DESCRIPTION
  Creates new users on Active directory and configures email address  
  .EXAMPLE
  New-User -emailaddress JohnS@contoso.com -Name John -Surname Smith
  .EXAMPLE
  New-User -emailaddress JohnS@contoso.com -Name John -Surname Smith -Location "Cape Town"
  .PARAMETER EmailAddress
  The email address of user to be created. email address is used to create user principle name
  .PARAMETER Name
  First name of user
  .PARAMETER Surname
  Surname of the user
  .PARAMETER Location
  City the user is based in, used to place into relevant organizational unit. Please use "Cape Town", Durban (Validatset has bug with spaces and the workaround is too hectic to bother)
  #>

[cmdletbinding()] 
param(
[Parameter(Mandatory=$true)]
[String]$emailaddress,
[Parameter(Mandatory=$true)]
[String]$Name,
[Parameter(Mandatory=$true)]
[String]$Surname,
[Parameter()]
[String]$Location


)



#import-module ppfunctions

#checks if user email address exists in Active Directory, if not continues script

if(!$(get-aduser -filter {emailaddress -eq $emailaddress}) )
{
 
#getting relevant username from email address and creating full name
    
    $username = $emailaddress.substring(0,$emailaddress.IndexOf('@'))
    $displayname = "$($name) $($surname)"

#creating key value pairs for Account creation
    
    $newparm = @{'samaccountname'=$username; 
             'name'=$displayname; 
             'givenname'=$name;
             'Surname'= $surname;
             'DisplayName'=$displayname;
             'EmailAddress'=$emailaddress;
             'UserPrincipalName'=$emailaddress}

    
    if($location)
        {  
          $ou= "OU=Users,$(get-adorganizationalunit -Filter 'Name -like $location')" 
          $newparm.add('path',$ou) 
        }

        

               
    New-Aduser @newparm

    $user = get-aduser -filter {emailaddress -eq $emailaddress} 

    write-host "Set a password for the user"

    $user | set-adaccountpassword -reset

#Creating email address in Active Directory 

    $user | set-aduser  -Add @{proxyaddresses="SMTP:$emailaddress"; targetaddress="SMTP:$username@contoso.com.mail.onmicrosoft.com"}

    $user | Enable-Adaccount 

#Calling function from PPFunctions module, this needs to be imported if not already part of profile 

    invoke-dirsync

}



else {

write-host "Email address already exists in Active Directory"

     }


                       
                       
}