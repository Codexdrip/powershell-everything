$OUpath = "OU=IT,OU=NewUsers,DC=CHS,DC=LOCAL"
$OUtarget = "OU=Help Desk,OU=IT,OU=NewUsers,DC=CHS,DC=LOCAL"

$UsersToMove = Get-ADUser -filter * -SearchBase $OUpath | select -first 5

foreach($user in $UsersToMove){
    Write-Host "Moving $($user.SamAccountName) to $OUtarget"
    $userDN = (Get-ADUser -Identity $user.SamAccountName).DistinguishedName
    Move-ADObject -Identity $userDN -TargetPath $OUtarget
    Write-Host "Moved $($user.SamAccountName)"
}
write-host 'Done.'