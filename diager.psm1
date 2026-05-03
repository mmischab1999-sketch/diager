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

$prefix = "Diager >>> "

function get-diskstress {
    param (
        [switch]$free,
        [switch]$health,
        [switch]$defrag,
        [switch]$asobject
    )
    if (-not $free -and -not $health -and -not $defrag) {
        $free = $true
        $health = $true
        $defrag = $true
    }
    $result =@{}
    if ($free){
        $freeResult = @()
        if(-not $asobject){
            write-diager "GETTING" "Your disks free space..." -color cyan }
        try {
            $Drives = Get-PSDrive -PSProvider FileSystem | ? Free -ne $null -erroraction stop
            if(-not $asobject){
                write-diager "GOT" "Your disks free space" -color green }
            $Drives | % {
                $currentGB = [math]::Round($_.free / 1GB, 2)
                if ($_.free -gt 5GB) {
                    $status = "OK"
                    if(-not $asobject) {
                        write-diager "$status" "$_ free space is normal. Its $currentGB GB" -color green }
                } else {
                    $status = "WARNING"
                    if (-not $asobject) {
                        write-diager "$status" "$_ free space is less than 5GB. Its only $currentGB GB" -color yellow }
                }
                $FreeObject = [PSCustomObject]@{ Drive = $_.Name; FreeGB = $currentGB; Status = $status }
                $freeResult += $FreeObject
                $result.Free = $freeResult
            }  
        } catch {
            write-diager "COULDNT" "Get your disks free space" -color red
        }
    }
    if ($health){
        $healthResult = @()
        if(-not $asobject){
            write-diager "GETTING" "Your disks health status..." -color cyan }
        try {
            $Volumes = Get-Volume | ? DriveLetter -ne $null -ErrorAction Stop
            if(-not $asobject){
                write-diager "GOT" "Your disks health status" -color green }
            $volumes | % {
                if ($_.HealthStatus -eq "healthy") {
                    if(-not $asobject){
                        write-diager "OK" "$($_.DriveLetter) health is in order" -color green }
                } else {
                    if(-not $asobject){  
                        write-diager "WARNING" "$($_.driveletter) health is not in order" -color yellow }
                }
                $healthObject = [PSCustomObject]@{ DriveLetter = $_.driveletter; HealthStatus = $_.HealthStatus}
                $healthResult += $healthObject
                $result.Health = $healthResult
            }
        } catch {
            write-diager "COULDNT" "Get your disks free status"
        }
    }
    if ($defrag) {
        $defragResult = @()
        if (-not $asobject) {
            write-diager "GETTING" "Defragmentation analysis..." -color cyan }
        try {
            $partitions = Get-Partition | Where-Object DriveLetter -erroraction stop
            $partitions | % {
                $physicalDisk = Get-PhysicalDisk -DeviceNumber $_.DiskNumber -erroraction stop
                if ($physicalDisk.MediaType -eq "SSD") {
                    $type = "SSD"
                    if(-not $asobject){
                        write-diager "OK" "Drive $($_.driveletter) ($type) - defragmentation not needed (And might be harmful)" -color green }
                } else {
                    $type = "HDD"
                    if(-not $asobject){
                        write-diager "INFO" "Drive $($_.DriveLetter)($type) - can be defragmentated." -color cyan
                        write-host "$prefix Run " -nonewline 
                        write-host "Optimize-Volume -DriveLetter $($_.DriveLetter) -Defrag" -f yellow -NoNewline
                        write-host " for it." }
                }
                if ($type -eq "SSD") { $canbedefraged = $false} else { $canbedefraged = $true}
                $defragObject = [PSCustomObject]@{ DriveLetter = $_.driveletter; MediaType = $type; CanBeDefraged = $canbedefraged}
                $defragResult += $defragObject
                $result.Defrag = $defragResult
            }
        } catch {
            write-diager "COULDNT" "Get defragmentation analysis"
        }
    }
    if ($asobject) {
        return [PSCustomObject]$result
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
	write-host "$prefix [INFO]: AVAILABLE CMDLETS: Get-DiagerHelp , Get-DiskStress , Get-ServStatus, Get-LagProblem." -f green
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


Export-ModuleMember -Function Get-DiskStress, Get-ServStatus, Get-DiagerHelp, gds, gnss, gdh, get-lagproblem, get-lag, glp
