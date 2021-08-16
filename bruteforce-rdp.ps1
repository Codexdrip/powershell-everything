param ([int] $HoursToQuery, $FirewallDisplayName)
$ErrorActionPreference = 'Stop'

function Get-Errors {
    <#
    .SYNOPSIS
        Simply writes an error message to the console.
    .EXAMPLE
        Get-SecurityEvents -NumOfHours 24
    .INPUTS
        String
    .OUTPUTS
    
    .NOTES
        Author:  Chris H.
        Website: https://github.com/Codexdrip/powershell-everything
    #>
    param (
        $ErrorMsg
    )
    Write-Host 'The following error occurred... {0}' -f $ErrorMsg
}
function Get-SecurityEvents {
    <#
    .SYNOPSIS
        Returns an object of security events withing a given time frame. Specifically looking for events with the ID 4625.
    .DESCRIPTION
        Returns an object of security events withing a given time frame. Specifically looking for events with the ID 4625. Event ID 4624 is failed authorization events in the security log. This script needs to be run with elevated privileges. 
    .PARAMETER NumOfHours
        How far in the log should we go back in hours. If no input is given, the default is 1 hour.
    .EXAMPLE
        Get-SecurityEvents
    .EXAMPLE
        Get-SecurityEvents -NumOfHours 24
    .INPUTS
        Int32
    .OUTPUTS
        PSCustomObject
    .NOTES
        Author:  Chris H.
        Website: https://github.com/Codexdrip/powershell-everything
    #>
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()] # Provides default var if param not supplied.
        [int32]$NumOfHours = 1 # How far (in hours) in the sec logs do we want to go back? Default is 1 hour.
    )
    write-host 'Getting Security Events...'
    # Filter security event log for failed logon attempts for specific hours.
    try {
        #$all_events = Get-WinEvent -FilterHashtable @{Logname='Security'; ID=4625; StartTime="08/09/2021"; EndTime="08/10/2021"} -ErrorAction Stop

        if ($NumOfHours -gt 1) {
            write-host 'Getting all events. This may take awhile...'
        }
        # For past hour
        $all_events = Get-WinEvent -FilterHashtable @{Logname='Security'; ID=4625; StartTime=(get-date).AddHours(-($NumOfHours)); EndTime=(Get-Date)} -ErrorAction Stop

        Write-Host "Found $(($all_events).count) events."
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Get-Errors -ErrorMsg $ErrorMessage
    }
    return $all_events
}
function Update-FirewallBlockList {
    <#
    .SYNOPSIS
        Updates a given firewall rule with IPv4 addresses.
    .DESCRIPTION
         Updates a given firewall rule with IPv4 addresses. Updates the remote Ip addresses.
    .PARAMETER RuleName
        The display name of the rule we want to change.
     .PARAMETER BlockedIPs
        An array of IPv4 address that we want to block.
    .EXAMPLE
        Update-FirewallBlockList -RuleName "Block RDP Access" -BlockedIPs "1.1.1.1", "2.2.2.2"
    .EXAMPLE
        Update-FirewallBlockList -RuleName "Block RDP Access" -BlockedIPs $blockIPs
    .INPUTS
        [string]RuleName
        [string[]]BlockedIPs
    .OUTPUTS
        
    .NOTES
        Author:  Chris H.
        Website: https://github.com/Codexdrip/powershell-everything
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$BlockedIPs,
        
        [Parameter(Mandatory)]
        [string]$RuleName
    )
    try {
        # Update firewall rule
        Set-NetFirewallRule -DisplayName $RuleName -RemoteAddress $BlockedIPs -ErrorAction Stop
        write-host "Rule updated."
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Get-Errors -ErrorMsg $ErrorMessage
    }
    
}

function Get-UnathorizedAttempts {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$RuleName,
        [int32]$NumOfHours
    )

    if (Get-Module -ListAvailable -Name PSScriptTools) {
        Write-Host "PSScriptTools is installed. Loading module..."
        Import-Module PSScriptTools
    } 
    else {
        Write-Host "PSScriptTools Module does not exist. Installing the module..."
        install-module PSScriptTools
        Import-Module PSScriptTools
    }
    
    $all_events = Get-SecurityEvents -NumOfHours $NumOfHours 
    # Find all failed ip addresses in the last hour
    $failed_ips = $all_events | Convert-EventLogRecord | Group-Object 'IPAddress' -NoElement | sort -Property count -Descending

    write-host "Found these bad Ips..."
    $failed_ips

    $Ans = Read-Host "Do you want to add these IPs to your block list? Y/N"
    if ($Ans -eq 'Y') {
        # Add each bad ip to the $bad_ips arr
        $bad_ips = @()
        foreach ($ip in $failed_ips){
            if ($ip.count -ge 3){
                $bad_ips += $ip.name
            }
        }

        # Get the ips currently in the block list
        $blocked_ips = (Get-NetFirewallRule -DisplayName $RuleName | Get-NetFirewallAddressFilter).RemoteAddress

        # if the bad ip IS NOT in the block list add it to the block list
        foreach ($ip in $bad_ips) {
            if (!$blocked_ips.Contains($ip) ) { 
                $blocked_ips += $ip
            } 
            else { 
                write-host "Ip [$ip] already exist."
            }    
        }
        Update-FirewallBlockList -RuleName $RuleName -BlockedIPs $blocked_ips      
    }
    else {
        write-host "Exiting..."
    }
    
}


Get-UnathorizedAttempts -RuleName $FirewallDisplayName -NumOfHours $HoursToQuery










