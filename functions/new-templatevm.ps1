#work in progress
#$vmname = "test"
#$vmtype = "small"

#$vmswitch = (Get-VMSwitch -ComputerName $computername).Name

function new-templatevm{

[cmdletbinding()]

param(

[parameter(Mandatory)]
[string]$computername,

[Parameter(Mandatory)]
[string]$VmName,

[ValidateSet("Small","Medium","Large")]
[string]$VmType="Small",

[string]$VmSwitch = "TeamSwitch"


)

$vmpath = (get-vmhost -computername $computername).virtualmachinepath
$vdpath = Join-Path c:\hyper-v\ "test_C.vhdx" 

#set virtual machine configuration
Switch ($VMType) {
    "Small" {
        Write-Verbose "Setting Small values"
        $MemoryStartup=512MB
        $VHDSize=20GB
        $ProcCount=1
        $MemoryMinimum=512MB
        $MemoryMaximum=1GB
        Break
    }
    "Medium" {
        Write-Verbose "Setting Medium values"
        $MemoryStartup=1GB
        $VHDSize=40GB
        $ProcCount=2
        $MemoryMinimum=1GB
        $MemoryMaximum=2GB
        Break
    }
    "Large" {
        Write-Verbose "Setting Large values"
        $MemoryStartup=1GB
        $VHDSize=80GB
        $ProcCount=4
        $MemoryMinimum=1GB
        $MemoryMaximum=4GB
        Break
    }
    Default {
        Write-Verbose "Uh-Oh"
    }
    
}

#hash table for new-vm
$newparam = @{

 Name=$VmName
 SwitchName=$VMSwitch
 MemoryStartupBytes=$MemoryStartup
 Path=$VmPath
 NewVHDPath=$VDPath
 NewVHDSizeBytes=$VHDSize
 ErrorAction="Stop"

}

#hash table for Set-VM
$setParam = @{
 ProcessorCount=$ProcCount
 DynamicMemory=$True
 MemoryMinimumBytes=$MemoryMinimum
 MemoryMaximumBytes=$MemoryMaximum
 ErrorAction="Stop"
}

try{


$VM= new-vm @newparam

}

Catch{
write-warning $_.exception.message
return

}

if($vm) {

Try {
    Write-Verbose "Configuring new Virtual Machine $vmname"
    Write-verbose ($setParam | Out-String)
    $vm | set-vm @setparam
}

Catch {
    write-warning "Failed to configure Virtual Machine $vmname"
    Write-Warning $_.exception.Message
    Return
    }

    
    
}

}