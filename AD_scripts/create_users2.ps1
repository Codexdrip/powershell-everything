$csv = Import-Csv -Path .\ad_users.csv
#$first_three_users = $csv[0..2]


$counter = 1
$email_domain = '@chs.com'
$streetaddress = @('123 Rainbow Dr.', '124 Drainbow Rd.', '60 Greengrow Blvd.')
$city = @('Decatur', 'Atlanta', 'Dunwoody')
$zipcode = @('30030', '30034', '30035')
$state = @('GA', 'AL', 'NC')
$country = 'USA'
$department = @('Marketing', 'Sales', 'IT')
$password = 'Sully_Dully'
$telephone = 1111111110
$jobtitle = @('Marketing', 'Sales', 'IT')
$company = 'CHS'
$ou = ',OU=NewUsers,DC=CHS,DC=LOCAL'

foreach($user in $csv){
    $user.username = $user.firstname[0] + $user.lastname
    $user.email = $user.username + $email_domain
    $user.streetaddress = $streetaddress[(Get-Random -Maximum 3)]
    $user.city = $city[(Get-Random -Maximum 3)]
    $user.zipcode = $zipcode[(Get-Random -Maximum 3)]
    $user.state = $state[(Get-Random -Maximum 3)]
    $user.country = $country
    $user.department = $department[(Get-Random -Maximum 3)]
    $user.password = $password + $counter # Don't forget to increment
    $user.telephone = [string]($telephone + $counter)
    $user.jobtitle = $user.department
    $user.company = $company
    $user.ou = 'OU=' + $user.department + $ou

    write-host "The user: $($user.username) is being added..."
    
    # Try to create new AD user
    $CurrentUser = $user.username
    if(Get-ADUser -filter 'SamAccountName -eq $CurrentUser'){
        Write-Warning "A user with the name $($user.username) already exist"
    }
    else{
        $ADArgsSplat = @{
            SamAccountName = $user.username
            UserPrincipalName = "$($user.username)@CHS.LOCAL"
            Name = "$($user.firstname) $($user.lastname)"
            GivenName = $user.firstname
            Surname = $user.lastname
            Enabled = $True
            DisplayName = "$($user.firstname) $($user.lastname)"
            Path = $user.ou
            City = $user.city
            Company = $user.company
            State = $user.state
            StreetAddress = $user.streetaddress
            OfficePhone = $user.telephone
            EmailAddress = $user.email
            Title = $user.jobtitle
            Department = $user.department
            AccountPassword = ConvertTo-SecureString $user.password -AsPlainText -Force
        }
        New-ADUser @ADArgsSplat
    }

    $counter += 1
}

$csv | Export-Csv -Path .\newADusers_fullrun.csv

