function update-image {


[cmdletbinding()]
param (

[parameter(Mandatory=$true)]
[string]$mountdir,
[parameter(Mandatory=$true)]
[string]$imgpath,
[parameter()]
[string]$wsustargetgroup = "workstations",
[parameter()]
[string]$logfile="$imgpath-dism.log"

)


Add-Type -Path "$Env:ProgramFiles\Update Services\Api\Microsoft.UpdateServices.Administration.dll"

$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer("wsus", $False, "8530")

$UpdateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope

$UpdateScope.ApprovedStates = [Microsoft.UpdateServices.Administration.ApprovedStates]::LatestRevisionApproved

$TargetGroup = $wsus.GetComputerTargetGroups() | where { $_.Name -eq $wsustargetgroup }

$UpdateScope.ApprovedComputerTargetGroups.add($TargetGroup)



dism /mount-image /imagefile:$imgpath /index:1 /mountdir:$mountdir


$Installables = @{}

$wsus.GetUpdates($UpdateScope) | ForEach {
    Write-Debug "Processing hotfix $($_.Title) ..."

    # Get the files associated with an update and don't process PSF files
    $_.GetInstallableItems().Files | Where { $_.FileUri.LocalPath -match '.cab' } | ForEach {
        # Substitute the WSUS content path and replace slashes with backslashes
        $FileName = $_.FileUri.LocalPath.Replace('/Content', "C:\wsus\WsusContent").Replace('/', '\')
        Write-Debug "Processing installable file $FileName ..."

        # Make sure that the file really exists
        if ($(Test-Path "$FileName") -And -Not $Installables.ContainsKey($FileName)) {
            $Installables.Add($FileName, $_.Name)

        } else {
            Write-Debug "Installable file $FileName does not exist or has already been processed. Skipping."
        }
    }
}

$Installables.Keys | ForEach {
        $FileName = $_
        $Title = $Installables.Get_Item($FileName)

        Write-Host "Applying installable file $FileName ($Title) ..."
        # Add the update as an additional package to the mounted VHD file
        $PackageInfo = dism /Image:"$MountDir" /Get-PackageInfo /PackagePath:"$FileName"
        if ($($PackageInfo | where { $_ -eq "Applicable : Yes" } | Measure-Object -Line).Lines -eq 0) {
            Write-Debug "Package is not applicable to Image. Skipping."

        } elseif ($($PackageInfo | where { $_ -eq "Install Time : " } | Measure-Object -Line).Lines -eq 0) {
            Write-Debug "Package is already installed. Skipping."

        } elseif ($($PackageInfo | where { $_ -eq "Completely offline capable : Yes" } | Measure-Object -Line).Lines -eq 0) {
            Write-Warning "Package does not support offline servicing. Skipping."

        } else {
            $AddPackage = dism /Image:"$MountDir" /Add-Package /PackagePath:"$FileName"
            if ($($AddPackage | where { $_ -eq "The operation completed successfully." } | Measure-Object -Line ).Lines -eq 1) {
                Write-Debug "Successfully applied."
            } else {
                Write-Warning "Failed to apply. See log file $LogFile for details."
            }
        }
    }


dism /Unmount-Image /MountDir:$mountdir /commit


}



