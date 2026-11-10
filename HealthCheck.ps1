$computerName = [System.Environment]::MachineName
$uptime = Get-Uptime
$info = Get-ComputerInfo
$stopped = @(Get-Service | Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped'} )

$report = [pscustomobject]@{
    computerName = $computerName
    uptimeDays = $uptime.Days
    uptimeHours = $uptime.Hours
    uptimeMinutes = $uptime.Minutes
    osName = $info.OsName
    osVersion = $info.OsVersion
    stoppedAutoServices = $stopped.Count
    stoppedAutoNames = ($stopped | 
        Sort-Object Name| 
        Select-Object -First 5 | 
        Select-Object -ExpandProperty Name ) -join ', ' 
}

