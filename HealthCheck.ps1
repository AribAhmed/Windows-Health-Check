Set-StrictMode -Version Latest #Catch Errors

$computerName = [System.Environment]::MachineName #What's my machine's name?
$uptime = Get-Uptime #Get information about uptime such as how long my computer's been awake.
$info = Get-ComputerInfo #Get a variety of info of my computer, use Get-Member to find out what's hiding inside
$stopped = @(Get-Service | 
Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped'} )
#Check what services are stopped on my computer but automatically turn on with my computer
$lowThreshold = 25 #static int to check for hard drives under 25% storage

$disks = Get-CimInstance Win32_LogicalDisk | #Gather drive information 
    Where-Object {$_.DriveType -eq 3}  |  #Only where these drive objects are drive type 3
    Select-Object @{Name = "Name"; Expression = {$_.DeviceID}}, #Select from those objects, grab the device ID and list it under Name
    @{Name = "UsedGB"; Expression = {[math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2)}}, #Grab the Used amount of GB by getting the total size and subtracting how much free space is left
    @{Name = "FreeGB"; Expression = {[math]::Round($_.FreeSpace / 1GB, 2)}}, #the free amount of gb can be taken by getting the automatic variable 
    @{Name = "PercentFree"; Expression = {[math]::Round(($_.FreeSpace / $_.Size) * 100, 1)}} | #Calculate the percentage free by diving the free space by the total size and multiplying by 100|
    Select-Object *, 
    @{Name = "Warning"; Expression = { if ($_.PercentFree -lt $lowThreshold) 
        { 'LOW' }

        else 
        { 'OK' } 
    }} #Warning if percentage is under the threshold

$low = @($disks | Where-Object {$_.Warning -eq 'LOW'} | Select-Object -ExpandProperty Name) 
#pull up the disks variable, where the objects in warning subvariable is equal to low, select the object's name (expanded property helps cut the wrapper)
$lowDisks = if ($low.Count -gt 0){ 
    
    $low -join ', '
    
} else {

        'None'
}
#if low is greater than 0, join them together with a , else, write one
    
$report = [pscustomobject]@{ #create custom report object
    computerName = $computerName #the computer name is listed to the computer name
    uptimeDays = $uptime.Days 
    uptimeHours = $uptime.Hours
    uptimeMinutes = $uptime.Minutes
    osName = $info.OsName
    osVersion = $info.OsVersion
    stoppedAutoServices = $stopped.Count #the amount of stopped services using the $stopped we set aove
    stoppedAutoNames = ($stopped |  #get the variable above
        Sort-Object Name| #pipe into sorting them by their name alphabetically
        Select-Object -First 5 | #get the first 5
        Select-Object -ExpandProperty Name ) -join ', ' #expand their property and join them with a comma
    lowDisks = $lowDisks
    }

#creating net array with information
#get our net ip configuration
#onl where that object is inside our ipv4 default gateway 
#select the inteface alias 
#set custom variables in these columns that are being set to ip address, the gateway next hop, and dns server
$net = @(Get-NetIPConfiguration | 
    Where-Object {$_.IPv4DefaultGateway} | 
    Select-Object InterfaceAlias,
    @{Name = "IPAddress"; Expression = {$_.IPV4Address.IPAddress}},
    @{Name = "Gateway"; Expression = {$_.IPV4DefaultGateway.NextHop}},
    @{Name = "DNSServers"; Expression = {$_.DNSServer.ServerAddresses -join ', '}})
