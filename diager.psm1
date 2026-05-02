

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
	write-host " [GETTING]:" -f cyan -nonewline
	write-host "Your disks free space..."
start-sleep -seconds 1
	#если инфа о дисках получена 
	if ($drives -ne $null) {
		write-host "$prefix" -nonewline
		write-host " [GOT]:" -f green -nonewline
		write-host "Your disks free space" 
		$Drives | % {
        		if ($_.Free -gt 5GB) {
				$currentGB = [math]::Round($_.free / 1GB, 2)
        			write-host "$prefix" -nonewline
				write-host " [OK]:" -f green -nonewline
				write-host "$_ free space is normal. It`s $currentGB GB"
       			 } else {
				write-host "$prefix" -nonewline
				write-host " [WARNING]:" -f yellow -nonewline
				write-host "Less than 5GB free space on $_ disk! Use utilits to clean or delete files you don`t need"
			}
		}
	#если инфа о дисках не получена
	} else {
		write-host "$prefix" -nonewline
		write-host " [COULDN`T]:" -f red -nonewline
		write-host "Get your disks free space"
	}
	} #закрыл парам
	


	if ($health) {
	write-host "$prefix" -nonewline
	write-host " [GETTING]:" -f cyan -nonewline 
	write-host "Your disks health status..."
start-sleep -seconds 1
	if ($Volumes.DriveLetter -ne $null) {
		write-host "$prefix" -nonewline
		write-host " [GOT]:" -f green -nonewline
		write-host "Your disks health status"
		$Volumes | % {
			if ($_.HealthStatus -eq "Healthy") {
				write-host "$prefix" -nonewline
				write-host " [OK]:" -f green -nonewline
				write-host "$($_.DriveLetter) health is in order" 
			} else {
				write-host "$prefix" -nonewline
				write-host " [WARNING]:" -f yellow -nonewline 
				write-host "$($_.DriveLetter) health isnt in order! Use utilits or contact a specialist.P.S. $($_.OperationalStatus)"
			}
		}
	} else {
		write-host "$prefix" -nonewline
		write-host " [COULDN`T]:" -f red -nonewline
		write-host "Get your disks health status"
	}
} #закрыл парам

if ($defrag) {
	write-host "$prefix" -nonewline
	write-host " [GETTING]:" -f cyan -nonewline 
	write-host "Defragmentation analysis..."
    start-sleep -seconds 1
    
	if ($partitions -ne $null) {
		$partitions | ForEach-Object {
    		$physicalDisk = Get-PhysicalDisk -DeviceNumber $_.DiskNumber
    
   			if ($physicalDisk.MediaType -eq "SSD") {
        		Write-Host "$prefix" -nonewline
				write-host " [OK]:" -f green -nonewline
				write-host "Drive $($_.DriveLetter): (SSD) — defragmentation not needed and might be harmful."
    		} else {
        		Write-Host "$prefix" -nonewline
				write-host " [INFO]:" -f cyan -nonewline 
				write-host "Drive $($_.DriveLetter): (HDD) — if system feels slow, run:" -nonewline
				write-host " Optimize-Volume -DriveLetter $($_.DriveLetter) -Defrag" -f yellow
            }
        }
        write-host "$prefix" -nonewline
        write-host " [GOT]:" -f green -nonewline 
        write-host "Fragmentation information. Analysed"
	} else {
		write-host "$prefix" -nonewline
		write-host " [COULDN`T]:" -f red -nonewline
		write-host "Get fragmentation status" 
	}
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
		write-host "Your service statuses"
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
	write-host "$prefix [INFO]: AVAILABLE CMDLETS: Get-DiagerHelp , Get-DiskStress , Get-ServStatus, Get-BatteryReport (For laptops only), Get-LagProblem." -f green
	write-host "$prefix [INFO]: Links:" -f green
	write-host "$prefix [INFO]: PSGallery: https://www.powershellgallery.com/packages/diager/1.0" -f green
	write-host "$prefix [INFO]: GitHub: https://github.com/mmischab1999-sketch/diager " -f green
}

function gdh {
	get-diagerhelp @args
}



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



		





function Write-Diager {
    param(
        [string]$Tag,          # тэг
        [string]$Message,      # текст
        [string]$Color = "White",  # цвет тега
        [string]$MsgColor = "White", # цвет сообщения необязательно
        [switch]$NoNewline
    )
    Write-Host "$prefix " -NoNewline
    Write-Host "[$Tag]:" -ForegroundColor $Color -NoNewline
    if ($MsgColor -ne "White") {
        Write-Host " $Message" -ForegroundColor $MsgColor -NoNewline:$NoNewline
    } else {
        Write-Host " $Message" -NoNewline:$NoNewline
    }
}



function Get-Lagproblem {
	param (
		[switch]$cpu,
		[switch]$ram,
		[switch]$temp,
		[switch]$disk,
		[switch]$battery
	)

	if (-not $cpu -and -not $ram -and -not $temp -and -not $disk) {
		$cpu = $true
		$ram = $true
		$temp = $true
		$disk = $true
		$battery = $false
	}
	if ($cpu) {
		write-diager "GETTING" "CPU Load information…" -color cyan
		try {
			$processorTotal = (gcim win32_processor).loadpercentage
			write-diager "GOT" "CPU Load information." -color green
			if ($processorTotal -le 50) {
				write-diager "OK" "Total CPU Load: $processorTotal%" -color green
			} elseif ($processorTotal -lt 80) {
				write-diager "INFO" "Total CPU Load: $processorTotal%. Be careful." -color cyan
			} elseif ($processorTotal -ge 80 -and $processorTotal -lt 95) {
				write-diager "WARNING" "Total CPU Load: $processorTotal%. Check processes." -color yellow
			} elseif ($processorTotal -ge 95 -and $processorTotal -le 100) {
				write-diager "CRITICAL" "Total CPU Load: $processorTotal%. CPU maxed out!" -color red
			}
			$CPUTop = get-process | sort CPU -descending | select -first 5 name, cpu
			write-diager "INFO" "Top 5 hard-loading procceses:" -color cyan
			$CPUTop | % {
				write-host " > $($_.Name) : $([math]::Round($_.CPU, 1))s"
			}
		} catch {
			write-diager "COULDNT" "Get CPU Load information. Check, if you started the console as administrator." -color red 
		}
	}
	if ($disk) {
		Get-DiskStress -free
	}


	
	if ($temp) {
		write-diager "GETTING" "CPU Physical temperature..." -color cyan
		try {
			$cputemp = gcim -namespace root/wmi -className msacpi_thermalzoneTemperature -erroraction stop
			$cputempCelsius = ($cputemp.CurrentTemperature / 10) - 273.15
			write-diager "GOT" "CPU Physical temperature." -color green
			if ($cputempCelsius -le 60) {
				write-diager "OK" "CPU Temperature: $cputempCelsius°C" -color green
			} elseif($cputempCelsius -ge 61 -and $cputempCelsius -le 85) {
				write-diager "WARNING" "CPU Temperature: $cputempCelsius. That is hot, but its fine if you are using laptop. Check cooler if you are not." -color yellow
			} else {
				write-diager "CRITICAL" "CPU Temperature: $cputempCelsius. Danger zone!" -color red
			}
			
		} catch {
			write-diager "COULDNT" "Get CPU Physical temperature. Restart the console as administrator. Unless it helps - Temperature sensor not available on this system." -color red 
		}
	}
	
	if ($battery) {
		get-batteryreport -wear
	}

}
			
function get-lag {
	get-lagproblem @args
}

function glp {
	get-lagproblem @args
}


Export-ModuleMember -Function Get-DiskStress, Get-BatteryReport, Get-ServStatus, Get-DiagerHelp, gds, gbr, gnss, gdh, get-lagproblem, get-lag, glp
