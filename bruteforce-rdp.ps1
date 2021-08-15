$ErrorActionPreference = 'Stop'
#install-module PSScriptTools
#Import-Module PSScriptTools


function Get-SecurityEvents {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()] # Provides default var if param not supplied.
        [int32]$NumOfHours = 1 # How far (in hours) in the sec logs do we want to go back? Default is 1 hour.
    )
    write-host 'Getting Security Events...'
    # Filter security event log for failed logon attempts on specific day. Date:month/day/year.
    try {
        write-host 'Getting all events. This may take awhile...'
        $all_events = Get-WinEvent -FilterHashtable @{Logname='Security'; ID=4625; StartTime="08/09/2021"; EndTime="08/10/2021"} -ErrorAction Stop

        # For past hour
        # $all_events = Get-WinEvent -FilterHashtable @{Logname='Security'; ID=4624; StartTime=(get-date).AddHours(-1); EndTime=(Get-Date)}  
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host 'The following error occurred... {0}' -f $ErrorMessage
    }
    

    return $all_events
}
function Update-FirewallBlockList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$blocked_ips
    )
    # Update firewall rule
    Set-NetFirewallRule -DisplayName "Block RDP access" -RemoteAddress $blocked_ips
    write-host "Rule updated."
}



$all_events = Get-SecurityEvents    

# Find all failed ip addresses in the last hour
$failed_ips = $all_events | select -First 1000 | Convert-EventLogRecord | Group-Object 'IPAddress' -NoElement | sort -Property count -Descending

# Add each bad ip to the $bad_ips arr
$bad_ips = @()
foreach ($ip in $failed_ips){
    if ($ip.count -ge 3){
        $bad_ips += $ip.name
    }
}

# Get the ips currently in the block list
$blocked_ips = (Get-NetFirewallRule -DisplayName "Block RDP access" | Get-NetFirewallAddressFilter).RemoteAddress

# if the bad ip IS NOT in the block list add it to the block list
foreach ($ip in $bad_ips) {
    if (!$blocked_ips.Contains($ip) ) { 
        $blocked_ips += $ip
    } 
    else { 
        write-host 'Ip already exist.'
    }    
}

Update-FirewallBlockList($blocked_ips)




