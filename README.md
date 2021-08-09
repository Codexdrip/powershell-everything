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


### Discover objects, properties, & methods (Get-Member)
Get-Service -Name w32time | Get-Member 
Get-ADUser -Identity mike | Get-Member
Start-Service -Name w32time -PassThru | Get-Member

#### Find properties
Get-Service -Name w32time | Select-Object -Property *
Get-Service -Name w32time | Select-Object -Property Status, Name, DisplayName, ServiceType, Can*
Get-ADUser -Identity mike -Properties * | Get-Member

#### Once you know what type of object a command produces, you can use this information to find commands that accept that type of object as input.
Get-Command -ParameterType ServiceController

#### Find methods
Get-Service -Name w32time | Get-Member -MemberType Method
(Get-Service -Name w32time).Stop()
