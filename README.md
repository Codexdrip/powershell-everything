# PowerShell-Everything

## Core Commands

### Help
Get-Help -Name Get-Command -Full  
Get-Help -Name Get-Command -Detailed  
Get-Help -Name Get-Command -Examples  
Get-Help -Name Get-Command -Online  
Get-Help -Name Get-Command -Parameter Noun  
Get-Help -Name Get-Command -ShowWindow  
help *process*  
Update-Help  

### Locate Commands
Get-Command -Noun Process 
Get-Command -Noun CMI*   
Get-Command -Name *service*  
Get-Command -Name Test-MrCmdletBinding -Syntax  
(Get-Command -Name Test-MrCmdletBinding).Parameters.Keys  
Get-Command -ParameterName ComputerName  
Get-Command | Get-Random | Get-Help -Full  
Get-Command -Module ActiveDirectory
##### Once you know what type of object a command produces, you can use this information to find commands that accept that type of object as input.
Get-Command -ParameterType ServiceController 


### Discover objects, properties, & methods (Get-Member)

#### Find objects
Get-Service -Name w32time | Get-Member   
Get-ADUser -Identity mike | Get-Member  
Start-Service -Name w32time -PassThru | Get-Member  

#### Find properties
Get-Service -Name w32time | Select-Object -Property *  
Get-Service -Name w32time | Select-Object -Property Status, Name, DisplayName, ServiceType, Can*  
Get-ADUser -Identity mike -Properties * | Get-Member  

#### Find methods
Get-Service -Name w32time | Get-Member -MemberType Method  
(Get-Service -Name w32time).Stop()  


### Filtering & Formatting
#### Filter left, format right
Format-Table  
Format-List  
Format-Wide  
Format-Custom
### Alias
Get-Alias -Definition Get-Command, Get-Member

### Formatting
'{0}, age {1}, is in {2}' -f $name, $person.age, $person.city

### Saving to files
| Export-CSV -Path $path  
| Out-file -filepath $path 


### Arrays
$array = @(1,2,3,5,7,11)  
foreach($item in $array)  
{  
    Write-Output $item  
}   
Write-Output $array[3]  
$array[2] = 13

### Hashtables
$ageList = @{}  
$key = 'Kevin'  
$value = 36  
$ageList.add( $key, $value )  
$ageList.add( 'Alex', 9 )  
$ageList['Kevin']  
$ageList['Alex']  
$ageList['Alex'] = 9
##### Lookup table
$environments = @{  
    Prod = 'SrvProd05'  
    QA   = 'SrvQA02'  
    Dev  = 'SrvDev12'  
}  
$server = $environments[$env]  
#### Iterating hashtables
$ageList | Measure-Object  
$ageList.count  
$ageList.keys | ForEach-Object{  
    $message = '{0} is {1} years old!' -f $_,   $ageList[$_]  
    Write-Output $message  
}  
$ageList.GetEnumerator() | ForEach-Object{  
    $message = '{0} is {1} years old!' -f $_.key, $_.value  
    Write-Output $message  
}
#### Checking Hashtable for key/vals
if( $person.age -ne $null ){...}  
if( $person.ContainsKey('age') ){...}  
#### Remove/Clear keys
$person.remove('age')
$person.clear()
#### Dynamic assignments
$property = @{ 
    name = 'totalSpaceGB'  
    expression = { ($_.used + $_.free) / 1GB }  
}  
$drives = Get-PSDrive | Where Used  
$drives | Select-Object -Property name, $property
#### Splatting
##### Instead of saying on one line... 
Add-DhcpServerv4Scope -Name 'TestNetwork' -StartRange'10.0.0.2' -EndRange '10.0.0.254' -SubnetMask '255.255.255.0' -Description 'Network for testlab A' -LeaseDuration (New-TimeSpan -Days 8) -Type "Both"  
##### We can do splatting...
$DHCPScope = @{  
    Name        = 'TestNetwork'  
    StartRange  = '10.0.0.2'  
    EndRange    = '10.0.0.254'  
    SubnetMask  = '255.255.255.0'  
    Description = 'Network for testlab A'  
    LeaseDuration = (New-TimeSpan -Days 8)  
    Type = "Both"  
}  
Add-DhcpServerv4Scope @DHCPScope
##### Splatting optional params
$CIMParams = @{  
    ClassName = 'Win32_Bios'  
    ComputerName = $ComputerName  
}  
if($Credential)  
{  
    $CIMParams.Credential = $Credential  
}  
Get-CIMInstance @CIMParams
#### Nested Hashtables
$person = @{  
    name = 'Kevin'  
    age  = 36  
    location = @{  
        city  = 'Austin'  
        state = 'TX'  
    }  
}  
##### OR
$people = @{  
    Kevin = @{  
        age  = 36  
        city = 'Austin'  
    }  
    Alex = @{  
        age  = 9  
        city = 'Austin'  
    }  
}  
#### Convert to Json
$people | ConvertTo-Json   
{  
    "Kevin":  {  
                "age":  36,  
                "city":  "Austin"  
            },  
    "Alex":  {  
                "age":  9,  
                "city":  "Austin"  
            }  
}  

### Providers
#### A provider in PowerShell is an interface that allows file system like access to a datastore. There are a number of built-in providers in PowerShell.
Get-PSProvider  
Get-PSDrive


### Loops
#### ForEach-Object (Used to loop through pipes)  
'ActiveDirectory', 'SQLServer' |  
   ForEach-Object {Get-Command -Module $_} |  
     Group-Object -Property ModuleName   -NoElement |  
         Sort-Object -Property Count   -Descending    

#### foreach (When using the foreach keyword, you must store all of the items in memory before iterating through)
$ComputerName = 'DC01', 'WEB01'  
foreach ($Computer in $ComputerName) {  
  Get-ADComputer -Identity $Computer  
}  

#### also allowable in some cases
'DC01', 'WEB01' | Get-ADComputer  

#### For loop
for ($i = 1; $i -lt 5; $i++) {  
  Write-Output "Sleeping for $i seconds"  
  Start-Sleep -Seconds $i  
}  

#### Do loop 
##### Do Until runs while the specified condition is false.
$number = Get-Random -Minimum 1 -Maximum 10  
do {  
  $guess = Read-Host -Prompt "What's your   guess?"  
  if ($guess -lt $number) {  
    Write-Output 'Too low!'  
  }  
  elseif ($guess -gt $number) {  
    Write-Output 'Too high!'  
  }  
}  
until ($guess -eq $number)  
##### Do While is just the opposite. It runs as long as the specified condition evaluates to true.
$number = Get-Random -Minimum 1 -Maximum 10  
do {  
  $guess = Read-Host -Prompt "What's your   guess?"  
  if ($guess -lt $number) {  
    Write-Output 'Too low!'  
  } elseif ($guess -gt $number) {  
    Write-Output 'Too high!'  
  }  
}  
while ($guess -ne $number)

#### While loop
$date = Get-Date -Date 'November 22'  
while ($date.DayOfWeek -ne 'Thursday') {  
    $date = $date.AddDays(1)  
}  
Write-Output $date  

### CIM module
Get-Command -Module CimCmdlets  
Get-CimInstance -ClassName Win32_BIOS -Property SerialNumber |
Select-Object -ExpandProperty SerialNumber  
OR  
(Get-CimInstance -ClassName Win32_BIOS -Property SerialNumber).SerialNumber

#### Query Remote Computers with the CIM cmdlets
$CimSession = New-CimSession -ComputerName dc01 -Credential (Get-Credential)  
##### Now we can use that session to query remote computers
Get-CimInstance -CimSession $CimSession -ClassName Win32_BIOS
##### Close session
Get-CimSession | Remove-CimSession  

### Remoting
Enable-PSRemoting  
#### For one-to-one remoting we can use Enter-PSSession
$Cred = Get-Credential  
Enter-PSSession -ComputerName dc01 -Credential $Cred  
Exit-PSSession
#### For one-to-multiple remoting we can use Invoke-Command
$Cred = Get-Credential  
Invoke-Command -ComputerName dc01, sql02, web01 {Get-Service -Name W32time} -Credential $Cred 
Invoke-Command -ComputerName dc01, sql02, web01 {(Get-Service -Name W32time).Stop()} -Credential $Cred  
Invoke-Command -ComputerName dc01, sql02, web01 {Get-Service -Name W32time} -Credential $Cred  
#### We can kill overhead by creating one session instead of multiple instances
$Session = New-PSSession -ComputerName dc01, sql02, web01 -Credential $Cred  
Invoke-Command -Session $Session {(Get-Service -Name W32time).Start()}  
Invoke-Command -Session $Session {Get-Service -Name W32time}  
#### End session
Get-PSSession | Remove-PSSession

### Naming Convention
Get-Verb | Sort-Object -Property Verb

### Functions
function Get-Version {   
    $PSVersionTable.PSVersion  
}
#### Adv. Function w/Common Params
function Test-MrSupportsShouldProcess {  

    [CmdletBinding(SupportsShouldProcess)]  
    param (  
        $ComputerName  
    )  
  
    Write-Output $ComputerName  
  
}  
#### Function with mandatory param
function Test-MrParameterValidation {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ComputerName
    )

    Write-Output $ComputerName

}
#### Function with array of params
function Test-MrParameterValidation {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$ComputerName
    )

    Write-Output $ComputerName

}
#### Supply default param if one isn't given
function Test-MrParameterValidation {

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    Write-Output $ComputerName

}
#### Make verbose comments instead of inline comments for easier debugging
function Test-MrVerboseOutput {

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    foreach ($Computer in $ComputerName) {
        Write-Verbose -Message "Attempting to perform some action on $Computer"
        Write-Output $Computer
    }

}  
##### Then call the function like so...
Test-MrVerboseOutput -ComputerName Server01, Server02 -Verbose


#### Accept pipeline input by property name
function Test-MrPipelineInput {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    PROCESS {
            Write-Output $ComputerName
    }

}
#### Accept pipeline input by value (type)
function Test-MrPipelineInput {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string[]]$ComputerName
    )

    PROCESS {
        Write-Output $ComputerName
    }

}

### Exceptions
function Test-MrErrorHandling {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    PROCESS {
        foreach ($Computer in $ComputerName) {
            try {
                Test-WSMan -ComputerName $Computer -ErrorAction Stop
            }
            catch {
                Write-Warning -Message "Unable to connect to Computer: $Computer"
            }
        }
    }

}

### Comment-Based Help
function Get-MrAutoStoppedService {

<#
.SYNOPSIS
    Returns a list of services that are set to start automatically, are not
    currently running, excluding the services that are set to delayed start.

.DESCRIPTION
    Get-MrAutoStoppedService is a function that returns a list of services from
    the specified remote computer(s) that are set to start automatically, are not
    currently running, and it excludes the services that are set to start automatically
    with a delayed startup.

.PARAMETER ComputerName
    The remote computer(s) to check the status of the services on.

.PARAMETER Credential
    Specifies a user account that has permission to perform this action. The default
    is the current user.

.EXAMPLE
     Get-MrAutoStoppedService -ComputerName 'Server1', 'Server2'

.EXAMPLE
     'Server1', 'Server2' | Get-MrAutoStoppedService

.EXAMPLE
     Get-MrAutoStoppedService -ComputerName 'Server1' -Credential (Get-Credential)

.INPUTS
    String

.OUTPUTS
    PSCustomObject

.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (

    )

    #Function Body

}


### Begin & End blocks
BEGIN and END blocks are optional. BEGIN would be specified before the PROCESS block and is used to perform any initial work prior to the items being received from the pipeline. This is important to understand. Values that are piped in are not accessible in the BEGIN block. The END block would be specified after the PROCESS block and is used for cleanup once all of the items that are piped in have been processed.

### Creating Modules
Save functions in a .psm1 file and save the file in a location specified in $env:PSModulePath
Import-Module C:\MyScriptModule.psm1