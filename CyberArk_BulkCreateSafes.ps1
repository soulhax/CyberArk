<#
.SYNOPSIS
    Bulk create safes for users from CSV file.

.DESCRIPTION
    You will need to provide a CSV file of the users for which is the script going to create a safe.
    CSV file's first line/row should look like this "firstname,lastname" and then add your users below it in the same format.

    Also this script requires you to use PowerShell module for the CyberArk API which you can find here - https://github.com/pspete/psPAS

.EXAMPLE

.NOTES
    Filename: CyberArk_BulkCreateSafes.ps1
    Author: Kaarel Virroja
    Modified date: 2022-10-07
    Version 1.2 - Ask for description.
#>

#Ask for the CSV path
$File = Read-Host -Prompt "Please enter the CSV file path"

if ([string]::IsNullOrWhiteSpace($File)) {

    Write-Host "No path was given. Exiting the script."

} else {
    #Ask for the URL of PVWA
    $URL = Read-Host -Prompt "Please enter the URL for the PVWA"
    $DESC = Read-Host -Prompt "Description for safe (leave empty if not needed)"


    #Specify file location
    $Users = Import-Csv -Path $File

    #Specify Vault Logon Credentials
    $LogonCredential = Get-Credential

    #Logon
    New-PASSession -Credential $LogonCredential -BaseURI $URL

    #Create Safes. The {0} and {1} are where the variable swhich are going to be users firstname and lastname from the CSV file.
    foreach ($User in $Users){

        $FirstName = $User.firstname
        $LastName = $User.lastname
        $SafeName = "YOUR-SAFEFORMAT-{0}-{1}-HERE" -f $FirstName, $LastName

        Add-PASSafe -SafeName $SafeName -Description $DESC -ManagingCPM PasswordManager -NumberOfVersionsRetention 7

    }

    #Logoff
    Close-PASSession
}