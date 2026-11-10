$computerName = [System.Environment]::MachineName
$uptime = Get-Uptime
$uptimeDays = $uptime.Days
$uptimeHours = $uptime.Hours
$uptimeMinutes = $uptime.Minutes

Write-Host "Computer: $computerName
Uptime: $uptimeDays days, $uptimeHours hours, $uptimeMinutes minutes."