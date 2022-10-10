<#
.SYNOPSIS
    Bulk add users to safe from CSV file.

.DESCRIPTION
    You will need to provide a CSV file of the users who are going to be added into the safe members list.
    CSV file's first line/row should look like this "firstname,lastname" and then add your users below it in the same format.

    Also this script requires you to use PowerShell module for the CyberArk API which you can find here - https://github.com/pspete/psPAS

.EXAMPLE

.NOTES
    Filename: CyberArk_BulkAddSafeMembers.ps1
    Author: Kaarel Virroja
    Modified date: 2022-10-10
    Version 1.0 - Release.
#>

#Ask for the CSV path
$File = Read-Host -Prompt "Please enter the CSV file path"

if ([string]::IsNullOrWhiteSpace($File)) {

    Write-Host "No path was given. Exiting the script."

} else {
    #Ask for the URL of PVWA
    $URL = Read-Host -Prompt "Please enter the URL for the PVWA"

    #Ask if we're going to add the same users to the safe or not
    $SAME_USER = Read-Host "Add the same user to the safe as in CSV file? Yes/No"

    #Specify file location
    $Users = Import-Csv -Path $File

    #Loop to ask yes or no
    while("yes","no" -notcontains $SAME_USER) {
        $SAME_USER = Read-Host "Add the same user to the safe as in CSV file? Yes/No"
    }

    #If users enter's no then we are going to ask for a name that is going to be added into the safe
    if ($SAME_USER -eq "No") {
        $FirstName = Read-Host -Prompt "Please enter the first name"
        $LastName = Read-Host -Prompt "Please enter the last name"
        $Fullname = "{0}.{1}" -f $FirstName, $LastName
    }

    #Specify Vault Logon Credentials
    $LogonCredential = Get-Credential

    #Logon
    New-PASSession -Credential $LogonCredential -BaseURI $URL

    #Add users to safe's
    foreach ($User in $Users){

        $FirstName = $User.firstname
        $LastName = $User.lastname
        $SafeName = "YOUR-SAFEFORMAT-{0}-{1}-HERE" -f $FirstName, $LastName
        $Fullname = "{0}.{1}" -f $FirstName, $LastName

        $Role = [PSCustomObject]@{
            UseAccounts                            = $true
            RetrieveAccounts                       = $true
            ListAccounts                           = $true
            AddAccounts                            = $false
            UpdateAccountContent                   = $false
            UpdateAccountProperties                = $false
            InitiateCPMAccountManagementOperations = $false
            SpecifyNextAccountContent              = $false
            RenameAccounts                         = $false
            DeleteAccounts                         = $false
            UnlockAccounts                         = $false
            ManageSafe                             = $false
            ManageSafeMembers                      = $false
            BackupSafe                             = $false
            ViewAuditLog                           = $false
            ViewSafeMembers                        = $false
            RequestsAuthorizationLevel             = $false
            requestsAuthorizationLevel1            = $false
            requestsAuthorizationLevel2            = $false
            AccessWithoutConfirmation              = $false
            CreateFolders                          = $false
            DeleteFolders                          = $false
            MoveAccountsAndFolders                 = $false
        }

        $Role | Add-PASSafeMember -SafeName $SafeName -MemberName $Fullname -SearchIn Vault

    }

    #Logoff
    Close-PASSession
}