function Find-IllegalChar{
<#
.SYNOPSIS
Finds characters that are not allowed on OneDrive for Business and changes filename to allowed characters.
Illegal characters "# % * : < > ? / \ |" are removed, "&" is converted to "_" and double spaces is converted to a single space
This needs to be run before migrating folder to OneDrive for Business
.Example
Find-IllegalChar -Path c:\testfolder\


#>


[CmdletBinding(SupportsShouldProcess=$true)]
param(

[Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true)]
[string[]]$Path

)


Write-Verbose "Getting a list of all files in $Path"

$FileList = Get-ChildItem -Path $Path -Recurse  | Select-Object baseName, Directory,name,extension |  Where-Object {$_.BaseName -match '[\~\"\#\%\&\*\:\<>\?\/\\\{\|\}\.(\s\s)(\s_\s)]'}


    ForEach($File in $FileList){

                        Write-Verbose "Checking File: $File.Name"

                        $Original = $File.BaseName

                        $Replace = $Original



                            Switch -Regex($Replace){

                            '[\~\"\#\*\.\{\}\/\?\-\:\<\>]'{

                                $Replace = $Replace -replace ('[\~\"\#\*\.\{\}\/\?\-\:\<\>]',"")

    
                            }
            
                            '&'  {
 
 
                                $Replace = $Replace -replace ('&',"_") 
 
                            }    


                            '%'{   
    
                                $Replace = $Replace -replace ('%',"")

    
                                 }
                                             
                            '\s_\s'{

                                 $Replace = $Replace -replace ('\s_\s',"_")
            
                                }

                            '\s+'{

                                $Replace = $Replace -replace ('\s+'," ")
            
                              }

            
                     
            
                      }

                             
    if($Replace -ne $Original){
       
                                $Replace = $Replace.Trim()

                                Write-Verbose "$File.Basename is to be replaced with $Replace"

                                [string]$FileName = $Replace + ($File.Extension).ToString()
                                
                                [string]$FilePath = ($File.Directory).ToString() +"\" + ($File.Name).ToString()

                                
                                Rename-Item -Path $FilePath -NewName $FileName

                              }




}


  
  
  
  }


