
function stop-longprocess{

 [CmdletBinding()]
 Param(
 [Parameter(Mandatory=$true,Position=1)]
 [string]$name,
 [int]$hours
 
 )

 # should it handle multiple processes?

$ProcessActive = Get-Process -name $name -ErrorAction SilentlyContinue

if($ProcessActive -eq $null)
{

 write-host "$name is either not running or does not exist"

}

else

{
#Determines runtime of process
$currentdate=get-date
$startdate = ($ProcessActive).StartTime
$timerunning = New-TimeSpan -start $startdate -end $currentdate

if ($timerunning.hours -gt $hours)
  { 

 stop-process -name $name
 

   }

else { 
    
     write-host " Process has not been running for more than $hours hours "

     }

}



}



