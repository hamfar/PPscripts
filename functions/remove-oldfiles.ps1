function remove-oldfiles { 
<#
.SYNOPSIS
Removes files older than a certain amount of days and file extension. 
.Example
Remove-oldfiles -path c:\test, c:\test2 -days 365 -extension tmp, log

#>

[CmdletBinding()]
  param ( 
  [Parameter(Mandatory=$true,Position=1)]
  [string[]]$path,
  [int]$days=30,
  [Parameter(Mandatory=$true)]
  [string[]]$extension


  )
     

foreach ($location in $path) {
	
	Write-Host "Trying to delete files older than $days days, in the folder $location" -ForegroundColor Green
    
foreach($ext in $extension){
	    
	Get-ChildItem -Path $location -Recurse -Include "*.$ext" | WHERE {($_.CreationTime -le $(Get-Date).AddDays(-$days))} | Remove-Item -force 
}
   
    #removes empty folders

    gci -path $location -force -recurse | Where{$_.psiscontainer -and (gci $_.FullName -force -recurse|?{!$_.psiscontainer}).count -eq 0}| Remove-Item -recurse -force}

    
} 
