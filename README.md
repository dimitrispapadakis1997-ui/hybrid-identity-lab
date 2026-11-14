# Hybrid Identity Lab: Active Directory + Microsoft Entra ID

A home lab that connects an on-premises Active Directory domain to a Microsoft Entra ID tenant, so users are created on-prem and sign in to cloud services with the same identity.

**Status:** in progress. See the [progress log](docs/progress-log.md) for what is done.

## Goal

Build and document a small hybrid identity environment, the same pattern many companies use when moving from on-prem to Microsoft 365 and Azure.

## Architecture

```
+----------------------------+          +--------------------------+
|  On-prem (local VMs)       |          |  Microsoft cloud         |
|                            |          |                          |
|  Windows Server (DC)       |  sync    |  Microsoft Entra ID      |
|  - AD DS, DNS              | -------> |  tenant                  |
|  - Microsoft Entra Connect |          |  - synced users/groups   |
|                            |          |  - cloud sign-in         |
|  Windows client (joined)   |          |                          |
+----------------------------+          +--------------------------+
```

## Plan

- [ ] 1. Prepare the VM environment (hypervisor, virtual network, Windows Server and Windows client VMs)
- [ ] 2. Install AD DS and DNS, promote the first domain controller
- [ ] 3. Create the OU structure, groups and test users ([scripts](scripts/))
- [ ] 4. Set up the Entra ID tenant and add an alternate UPN suffix matching the tenant domain
- [ ] 5. Install Microsoft Entra Connect and enable password hash synchronization
- [ ] 6. Verify synced users and test cloud sign-in
- [ ] 7. Join a client machine to the domain and test sign-in
- [ ] 8. Document issues, fixes and lessons learned

## Notes worth remembering

- A non-routable on-prem domain suffix (for example `corp.local`) cannot be used for cloud sign-in as it is. Users need an alternate UPN suffix that matches a domain verified in the tenant.
- Run the sync scope test with a small OU first, then widen the scope.
- Never commit passwords, tenant IDs, domain admin credentials or exports with real user data.

## Repository structure

```
.
├── README.md
├── docs/
│   └── progress-log.md
└── scripts/
    ├── 01-create-ou-structure.ps1
    └── 02-create-test-users.ps1
```

## Skills used

Active Directory, DNS, Windows Server, Microsoft Entra ID, Microsoft Entra Connect, password hash synchronization, PowerShell.

---
Dimitris Papadakis · Network & Infrastructure Engineer · Trondheim, Norway
