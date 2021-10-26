function Get-LastLogon {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$File
    )
    $lou = gc -Path $File

    foreach($usr in $lou){
        get-ADuser -Identity $usr -Properties lastLogonDate | select SamAccountName, LastLogonDate, @{l="Exact Date"; e={((NEW-TIMESPAN –Start $_.LastLogonDate -End (Get-Date)) | select Days, Hours, Minutes)}} | Format-List    
    }
    
}