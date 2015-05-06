function enable-archive {


[cmdletBinding()]
param(
[Parameter(Mandatory=$true,Position=1)]
[string]$identity,
[string]$archivename="Online Archive"
     )


$archiveuser=get-aduser -filter {emailaddress -eq $identity}


if ($archiveuser.msexcharchivename -eq $null){

$archiveuser | set-aduser -add @{msexcharchivename = $archivename} -Replace @{msExchRemoterecipientType = 3}

$archiveuser | set-retentionpolicy "Archive Manual" -confirm

}

else {

write-host "User already has archive entry: $archiveuser.msexcharchivename"
} 




}


