$script:diagerBannerShown = $false

$prefix = "Diager >>> "

function Get-DiskStress {
	
	param(
		[switch]$health,
		[switch]$defrag,
		[switch]$free
	)

	#переменные
	$Drives = Get-PSDrive -PSProvider FileSystem | ? Free -ne $null
	$Volumes = Get-Volume | ? DriveLetter -ne $null
	$partitions = Get-Partition | Where-Object DriveLetter

if (-not $health -and -not $defrag -and -not $free) {
    # show all
    $free = $true
    $health = $true
    $defrag = $true
}
	
	
if ($free) {
	write-host "$prefix" -nonewline
	write-host "[GETTING]:" -f cyan -nonewline
	write-host "Your disks free space..."
start-sleep -seconds 1
	#если инфа о дисках получена 
	if ($drives -ne $null) {
		write-host "$prefix" -nonewline
		write-host "[GOT]:" -f green -nonewline
		write-host "Your disks free space" 
		$Drives | % {
        		if ($_.Free -gt 5GB) {
				$currentGB = [math]::Round($_.free / 1GB, 2)
        			write-host "$prefix" -nonewline
				write-host "[OK]:" -f green -nonewline
				write-host "$_ free space is normal. It`s $currentGB GB"
       			 } else {
				write-host "$prefix" -nonewline
				write-host "[WARNING]:" -f yellow -nonewline
				write-host "Less than 5GB free space on $_ disk! Use utilits to clean or delete files you don`t need"
			}
		}
	#если инфа о дисках не получена
	} else {
		write-host "$prefix" -nonewline
		write-host "[COULDN`T]:" -f red -nonewline
		write-host "Get your disks free space"
	}
	} #закрыл парам
	


	if ($health) {
	write-host "$prefix" -nonewline
	write-host "[GETTING]:" -f cyan -nonewline 
	write-host "Your disks health status..."
start-sleep -seconds 1
	if ($Volumes.DriveLetter -ne $null) {
		write-host "$prefix" -nonewline
		write-host "[GOT]:" -f green -nonewline
		write-host "Your disks health status"
		$Volumes | % {
			if ($_.HealthStatus -eq "Healthy") {
				write-host "$prefix" -nonewline
				write-host "[OK]:" -f green -nonewline
				write-host "$($_.DriveLetter) health is in order" 
			} else {
				write-host "$prefix" -nonewline
				write-host "[WARNING]:" -f yellow -nonewline 
				write-host "$($_.DriveLetter) health isnt in order! Use utilits or contact a specialist.P.S. $($_.OperationalStatus)"
			}
		}
	} else {
		write-host "$prefix" -nonewline
		write-host "[COULDN`T]:" -f red -nonewline
		write-host "Get your disks health status"
	}
} #закрыл парам

if ($defrag) {
	write-host "$prefix" -nonewline
	write-host "[GETTING]:" -f cyan -nonewline 
	write-host "Defragmentation analysis..."
start-sleep -seconds 1
	if ($partitions -ne $null) {
		$partitions | ForEach-Object {
    			$physicalDisk = Get-PhysicalDisk -DeviceNumber $_.DiskNumber
    
   				 if ($physicalDisk.MediaType -eq "SSD") {
        				Write-Host "$prefix" -nonewline
					write-host "[OK]:" -f green -nonewline
					write-host "Drive $($_.DriveLetter): (SSD) — defragmentation not needed and might be harmful."
    				} else {
        				Write-Host "$prefix" -nonewline
					write-host "[INFO]:" -f cyan -nonewline 
					write-host "Drive $($_.DriveLetter): (HDD) — if system feels slow, run:" -nonewline
					write-host " Optimize-Volume -DriveLetter $($_.DriveLetter) -Defrag" -f yellow
}
    				}
	} write-host "$prefix" -nonewline
	  write-host "[GOT]:" -f green -nonewline 
	  write-host "Fragmentation information. Analysed"
			
	} else {
		write-host "$prefix" -nonewline
		write-host "[COULDN`T]:" -f red -nonewline
		write-host "Get fragmentation status" 
	}
} 

			
		



function gds {
	get-diskstress @args
}



function Get-ServStatus {
	write-host "$prefix " -nonewline
	write-host "[GETTING]: " -f cyan -nonewline
	write-host "Your service statuses..."
	Start-Sleep -Seconds 1

		#переменные для служб
	$fw = gsv | ? name -eq "mpssvc" #Firewall
	$ips = gsv | ? name -eq "PolicyAgent" #IPSec protocol
	$sc = gsv | ? name -eq "wscsvc" # security center
	$wd = gsv | ? name -eq "WinDefend" #windows defender
	$wu = gsv | ? name -eq "wuauserv" #windows update
	$ts = gsv | ? name -eq "w32time" #windows time service
	$wa = gsv | ? name -eq "audiosrv" #audio service

			# массив
	$services = @($fw, $ips, $sc, $wd, $wu, $ts, $wa)

	if ($services.Count -gt 0) {
		Write-Host "$prefix " -nonewline
		write-host "[GOT]:" -f green -nonewline
		write-host "Your services status"
			$services | ForEach-Object {
				#условия для цветов. филлер полнейший
				if ($_.Status -eq "Running") {
       					 $color = "Green"
    				} elseif ($_.Status -eq "Stopped") {
       					 $color = "Red"
    				} else {
       					 $color = "Yellow"  
    				}
				try {
					Write-Host "$prefix $($_.DisplayName) service is" -nonewline
					write-host " $($_.Status)" -f $color
				} catch {
					Write-Host "$prefix"-nonewline
					write-host "[COULDN'T]" -f red -nonewline
					write-host ": Get $($_.DisplayName) service status. Check if PowerShell console started as administrator"
				}
			}
		} else {
			Write-Host "$prefix " -nonewline
			write-host "[COULDN'T]" -f red -nonewline
			write-host ": Get your services status. Check if PowerShell console started as administrator."
	}
}


function gnss {
	get-servstatus @args
}


function get-diagerhelp {
	write-host "$prefix [INFO] AVAILABLE CMDLETS: Get-DiagerHelp , Get-DiskStress , Get-ServStatus, Get-BatteryReport (For laptops only)" -f green
}

function gdh {
	get-diagerhelp @args
}


$prefix = "Diager >>> "


function get-batteryreport {
param (
	[switch]$charge,
	[switch]$manufacturer,
	[switch]$wear,
	[switch]$cycle
)
if (-not $charge -and -not $cycle -and -not $manufacturer -and -not $wear) {
	$charge = $true
	$cycle = $true
	$manufacturer = $true
	$wear = $true
}

	write-host "$prefix" -nonewline
	write-host "[GETTING]:" -f cyan -nonewline
	write-host "Battery information..."
	$battery = gcim win32_battery
	if ($battery -eq $null) {
		write-host "$prefix" -nonewline
		write-host "[COULDN`T]" -f red -nonewline
		write-host ":Get any battery information. Suggest you're using PC?" 
	} else {
		write-host "$prefix" -nonewline
		write-host "[GOT]:" -f green -nonewline
		write-host "Battery information" 
		
		if($manufacturer){
		$manufacturerF = $battery.manufacturer
		write-host "$prefix" -nonewline
		write-host "[INFO]:" -f cyan -nonewline
		write-host "Manufacturer: $manufacturerF"
		}
		
		if($charge){
		$currentCharge = $battery.EstimatedChargeRemaining
		$batteryStatus = $battery.BatteryStatus
		if ($batteryStatus -eq 1) {
			$batteryStatus = "On battery"
		} else {
			$batteryStatus = "On charge" 
		}
			if ($currentCharge -gt 20) {
				write-host "$prefix" -nonewline
				write-host "[WARNING]:" -f yellow -nonewline
				write-host "Charge ($batteryStatus): $currentCharge, Charge up!"
			} else {
				write-host "$prefix" -nonewline
				write-host "[OK]:" -f green -nonewline
				write-host "Charge ($batteryStatus): $currentCharge"
			}
		}

		

		if($wear){
		$wearF = 100 - [math]::Round(($battery.FullChargeCapacity / $battery.DesignCapacity) * 100, 1)
		if ($wearF -ge 35 -and $wearF -lt 80){
			write-host "$prefix" -nonewline
			write-host "[WARNING]" -f yellow -nonewline
			write-host ":Battery wear: $wearF - consider replacing soon."
		}
		elseif ($wearF -ge 80){
			write-host "$prefix" -nonewline
			write-host "[CRITICAL]" -f red -nonewline
			write-host ":Battery wear: $wearF - replace it!"
		} else {
			write-host "$prefix" -nonewline
			write-host "[OK]" -f green -nonewline
			write-host ":Battery wear: $wearF"
			}
		}
	

		if($cycle) {
		$cycleF = $battery.cyclecount
			write-host "$prefix" -nonewline
			write-host "[INFO]" -f cyan -nonewline
			write-host "Interesting: you charged your laptop $cycleF times."
		}
	}
}
		
function gbr {
	get-batteryreport @args
}


Export-ModuleMember -Function Get-DiskStress, Get-BatteryReport, Get-ServStatus, Get-DiagerHelp, gds, gbr, gnss, gdh

$moduleVersion = (Test-ModuleManifest $PSScriptRoot\diager.psd1).Version
		
if (-not $script:diagerBannerShown) {
	#=======ИМПОРТ ВЕЛКОМ МЕССЕДЖ============	
write-host "╔═════════════════════════════════════════╗" -f cyan
write-host "║  DIAGER v$moduleVersion-alpha Diagnostics Module   ║" -f cyan
write-host "╚═════════════════════════════════════════╝" -f cyan
write-host "Diager >>> Welcome! Type" -nonewline
write-host " Get-DiagerHelp" -f yellow -nonewline
write-host " or" -nonewline
write-host " gdh" -f yellow -nonewline
write-host " to see available cmdlets."
$script:diagerBannerShown = $true
}
