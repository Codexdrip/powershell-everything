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
Get-Command -Name *service*  
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


### Providers
#### A provider in PowerShell is an interface that allows file system like access to a datastore. There are a number of built-in providers in PowerShell.
Get-PSProvider  
Get-PSDrive


### Loops
#### ForEach-Object (Used to loop through pipes)  
'ActiveDirectory', 'SQLServer' |
   ForEach-Object {Get-Command -Module $_} |
     Group-Object -Property ModuleName -NoElement |
         Sort-Object -Property Count -Descending  

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
  $guess = Read-Host -Prompt "What's your guess?"
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
  $guess = Read-Host -Prompt "What's your guess?"
  if ($guess -lt $number) {
    Write-Output 'Too low!'
  } elseif ($guess -gt $number) {
    Write-Output 'Too high!'
  }
}
while ($guess -ne $number)




