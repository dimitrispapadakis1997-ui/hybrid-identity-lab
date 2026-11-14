<#
.SYNOPSIS
    Creates a basic OU structure for the lab domain.
.DESCRIPTION
    Run on the domain controller in an elevated PowerShell session.
    Safe to run more than once: existing OUs are skipped.
#>

Import-Module ActiveDirectory

$domainDN = (Get-ADDomain).DistinguishedName
$rootOU   = "Lab"
$children = @("Users", "Groups", "Computers", "Admins")

function New-LabOU {
    param([string]$Name, [string]$Path)

    $dn = "OU=$Name,$Path"
    if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$dn'" -ErrorAction SilentlyContinue) {
        Write-Host "Exists:  $dn"
    }
    else {
        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $true
        Write-Host "Created: $dn"
    }
}

New-LabOU -Name $rootOU -Path $domainDN

foreach ($child in $children) {
    New-LabOU -Name $child -Path "OU=$rootOU,$domainDN"
}
