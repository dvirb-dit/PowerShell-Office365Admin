# Bulk add additional licences to a list of users.
#
# An updated version of my previous MSOL script, now using AzureAD.
#
# List of available SKUs can be obtained with (Get-AzureADSubscribedSku).SkuPartNumber
#

# Where is the list of user UPN's?
$userListPath = 'C:\Temp\UserList.txt'

# What licences are we adding?
$licencesToAdd = @('MCOMEETADV')

# Import MSOnline module and connect
Import-Module AzureAD
Connect-AzureAD

# Import list of users from file
$userList = Get-Content -Path $userListPath | Sort-Object

# Get all available licence skus
$newSkuIDs = (Get-AzureADSubscribedSku | Where-Object {$_.SkuPartNumber -in $licencesToAdd}).SkuId

# Create a licenses object
$newLicenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

# Add the licences to add to the licences object
foreach ($newSkuID in $newSkuIDs) {
    $newLicense = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
    $newLicense.SkuId = $newSkuID
    $newLicenses.AddLicenses += $newLicense
}

# Add the new licenses
foreach ($username in $userList) {
    $user = Get-AzureADUser -ObjectId $username
    if ($user.AccountEnabled -eq $true) {
        Set-AzureADUserLicense -ObjectId $user.UserPrincipalName -AssignedLicenses $newLicenses
        Write-Output -InputObject ('Licence added to user account ' + $user.UserPrincipalName + '.')
    }
    else {
        Write-Output -InputObject ('User account ' + $user.UserPrincipalName + ' is disabled.')
    }
}

# Disconnect from AzureAD
Disconnect-AzureAD
