<#
.SYNOPSIS
    Creates test users in the lab OU.
.DESCRIPTION
    Run on the domain controller after 01-create-ou-structure.ps1.
    The password is entered at runtime and is never stored in the script.
.PARAMETER UpnSuffix
    The UPN suffix to use, e.g. the verified domain of your Entra ID tenant.
.EXAMPLE
    .\02-create-test-users.ps1 -UpnSuffix "yourtenant.onmicrosoft.com"
#>

param(
    [Parameter(Mandatory)]
    [string]$UpnSuffix
)

Import-Module ActiveDirectory

$domainDN = (Get-ADDomain).DistinguishedName
$usersOU  = "OU=Users,OU=Lab,$domainDN"
$password = Read-Host -Prompt "Password for the test users" -AsSecureString

$testUsers = @(
    @{ First = "Test"; Last = "User1"; Sam = "test.user1" },
    @{ First = "Test"; Last = "User2"; Sam = "test.user2" },
    @{ First = "Test"; Last = "User3"; Sam = "test.user3" }
)

foreach ($u in $testUsers) {
    if (Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'" -ErrorAction SilentlyContinue) {
        Write-Host "Exists:  $($u.Sam)"
        continue
    }

    New-ADUser `
        -Name "$($u.First) $($u.Last)" `
        -GivenName $u.First `
        -Surname $u.Last `
        -SamAccountName $u.Sam `
        -UserPrincipalName "$($u.Sam)@$UpnSuffix" `
        -Path $usersOU `
        -AccountPassword $password `
        -Enabled $true `
        -ChangePasswordAtLogon $false

    Write-Host "Created: $($u.Sam)@$UpnSuffix"
}
