# Progress log

One entry per work session: what I did, what broke, how I fixed it. Screenshots are in [screenshots.md](screenshots.md).

## Entries

### 2026-11-23: Step 1, preparing the VM environment

- **Done:**
  - Chose VirtualBox as the hypervisor, because the host laptop runs Windows 11 Home (no Hyper-V).
  - Checked the host: 6 cores / 12 threads, 16 GB RAM, virtualization enabled in UEFI, plenty of free disk on a second SSD (D:), where the VM disks will live.
  - Downloaded VirtualBox 7.2.22.
  - Downloaded the Windows Server 2022 Evaluation ISO (about 4.7 GB, 180-day evaluation, free).
  - Downloaded the Windows 11 Enterprise Evaluation ISO for the domain-joined client (free 90-day evaluation).
- **Problem:** The Microsoft Evaluation Center asks for a registration form before each ISO download.
- **Fix:** Filled in the form once per product; marketing opt-ins left unchecked.
- **Next:** Install VirtualBox, create the Windows Server 2022 VM, install the OS, set a static IP.

### 2026-11-23: Steps 1 and 2, DC01 built and promoted to domain controller

- **Done:**
  - Installed VirtualBox and created the VM `DC01`: 3 GB RAM, 2 vCPUs, 50 GB disk on D:, two network adapters (Adapter 1 NAT for internet, Adapter 2 internal network `intnet` for the lab).
  - Installed Windows Server 2022 Standard Evaluation (Desktop Experience) and the VirtualBox Guest Additions.
  - Renamed the server to `DC01` and set a static IP on the internal adapter: `10.10.10.10/24`, DNS pointing to itself (`127.0.0.1`).
  - Installed the AD DS and DNS roles and promoted DC01 to the first domain controller of a new forest, `lab.local` (NetBIOS name `LAB`):
    `Install-ADDSForest -DomainName lab.local -DomainNetbiosName LAB -InstallDns ...`
  - Ran `scripts/01-create-ou-structure.ps1`: created `OU=Lab` with the child OUs `Users`, `Groups`, `Computers` and `Admins`.
- **Problem:** The VM did not accept keystrokes injected from the host (Ctrl+Alt+Del on the lock screen, typing into the console).
- **Fix:** Sent Ctrl+Alt+Del from the VirtualBox menu (Input > Keyboard), and ran commands by pasting them into an elevated PowerShell window. The DSRM (Directory Services Restore Mode) password is typed by hand at a `Read-Host -AsSecureString` prompt, so it never appears in a script or in this log.
- **Problem:** A routine restart showed the Shutdown Event Tracker dialog.
- **Fix:** Cancelled the dialog; it is the normal Windows Server prompt that asks for a restart reason.
- **Lesson:** Saving the VM state (close the window, "Save the machine state") is a quick way to pause the lab and resume exactly where it stopped.
- **Next:** Create the test users (`02-create-test-users.ps1`), set up the Entra ID tenant, add the alternate UPN suffix, then install Microsoft Entra Connect.

### 2026-11-23: Steps 3 and 4, Entra ID tenant, UPN suffix and test users

- **Done:**
  - Created a free Azure account, which creates a default Microsoft Entra ID tenant (license: Microsoft Entra ID Free). Its primary domain is of the form `<name>.onmicrosoft.com`.
  - Created a cloud-only administrator account in the tenant (`labadmin`, Global Administrator) for Microsoft Entra Connect. A personal Microsoft account cannot be used for that, because it is an external identity in the tenant.
  - Added the tenant domain as an alternate UPN suffix in the on-prem forest:
    `Set-ADForest -Identity lab.local -UPNSuffixes @{Add='<name>.onmicrosoft.com'}`
  - Ran `scripts/02-create-test-users.ps1 -UpnSuffix <name>.onmicrosoft.com`: created `test.user1`, `test.user2` and `test.user3` in `OU=Users,OU=Lab`, with UPNs on the tenant domain. The password is typed at a prompt and never stored.
- **Problem:** The first sign-in to the Entra admin center with a personal Microsoft account failed: "user account does not exist in tenant 'Microsoft Services'".
- **Fix:** A personal account has no tenant of its own. Signing up for a free Azure account created the directory. The Microsoft 365 Developer Program was not an option, because it requires a Visual Studio subscription or a qualifying program.
- **Problem:** The Entra admin center showed a stale user list right after creating the user, so the new account looked missing.
- **Fix:** A full page reload showed the account; creating it a second time was blocked by "User principal name already exists".
- **Lesson:** A free Azure sign-up asks for a card for identity verification. I did not create any paid resources.
- **Next:** Install Microsoft Entra Connect on DC01 with password hash synchronization, scoped to `OU=Lab` first, then verify the synced users and test cloud sign-in.

### 2026-11-24: Steps 5 and 6, Microsoft Entra Connect installed, users synced, cloud sign-in verified

- **Done:**
  - Installed Microsoft Entra Connect Sync 2.6.92.0 on DC01 with custom settings: password hash synchronization, Entra Connect creates its own AD connector account, and the cloud-only Global Administrator is used for the tenant connection.
  - Limited the sync scope to `OU=Lab` only (Domain/OU filtering), so the built-in containers and domain controllers stay on-prem.
  - Let the wizard run the first synchronization. `test.user1`, `test.user2` and `test.user3` appeared in the Entra admin center, with UPNs on the tenant domain and a creation time matching the end of the wizard, so they came from the sync and not from the portal.
  - Signed in to the cloud as `test.user1` with the on-prem AD password: the account shows up as signed in, so password hash sync works.
- **Problem:** The Entra Connect installer is no longer offered on the Microsoft Download Center (only a decommission notice), and the download link returned an HTML page.
- **Fix:** Downloaded the installer from the Entra Connect page of the Entra admin center on the host, checked its Microsoft digital signature, and shared it into the VM through a read-only VirtualBox shared folder. The VM's Edge is too old for the portal, so downloading inside the VM was not an option.
- **Problem:** The "AD forest account" step failed with "The user name or password is incorrect".
- **Fix:** The credentials field had kept the old text and my paste was appended to it. After clearing the field and entering `LAB.LOCAL\Administrator` plus the correct password, the step passed. Lesson: clear a field before pasting, and type the password by hand.
- **Problem:** The sign-in page showed "Not Added" for both UPN suffixes, even for the tenant's `.onmicrosoft.com` domain, which is always verified.
- **Fix:** Ticked "Continue without matching all UPN suffixes to verified domains". The users still synced with the right UPN, so the warning was only cosmetic here.
- **Lesson:** The wizard warns that the AD Recycle Bin is not enabled and recommends a TPM. Both are normal for a lab VM.
- **Next:** Create the Windows 11 client VM on the internal network, point its DNS to `10.10.10.10`, join it to `lab.local` and test a domain sign-in with a test user. Then write the final documentation.

### 2026-11-24: Steps 1 and 7, Windows 11 client joined to the domain, domain sign-in verified

- **Done:**
  - Created the VM `CLIENT01` in VirtualBox: Windows 11 Enterprise Evaluation, 4 GB RAM, 2 vCPUs, 80 GB disk, EFI, TPM 2.0 and Secure Boot (VirtualBox provides them for a Windows 11 guest). The unattended install created a local administrator and installed the Guest Additions.
  - Added a second network adapter on the internal network `intnet` (after the install, with the VM powered off), renamed it `LAB`, and gave it a static IP: `10.10.10.20/24`, DNS `10.10.10.10` (DC01) on every adapter.
  - Checked the connection to the DC: ping to `10.10.10.10` works and `Resolve-DnsName lab.local` returns the domain controller.
  - Joined the machine to the domain, into the Lab computers OU:
    `Add-Computer -DomainName lab.local -Credential LAB\Administrator -OUPath 'OU=Computers,OU=Lab,DC=lab,DC=local' -Restart`
    The credentials are typed in the prompt window, never in the command.
  - Signed in to CLIENT01 as the domain user `LAB\test.user1` (the Start menu shows `test.user1`). The same account, with the same password, also signs in to the Microsoft cloud, which is the point of the lab.
  - Changed the interface language of VirtualBox to English, and opened the Entra admin center with `?l=en.en-us`, so that screenshots are readable for everyone.
- **Problem:** `lab.local` also resolves to `10.0.2.15`, the NAT address of DC01, because the DC registers every adapter in DNS.
- **Fix:** Not needed here, since the join and the sign-in worked. In a production design I would disable DNS registration on the NAT adapter of the DC, or give it only one network card.
- **Problem:** Windows 11 kept signing in automatically as the local administrator, because the unattended install turns on auto-logon.
- **Fix:** Set the Winlogon value `AutoAdminLogon` to `0` and removed `DefaultPassword`. After that, "Other user" on the sign-in screen accepted the domain account.
- **Problem:** Pasting into the guest did nothing at first.
- **Fix:** Turned on Devices > Shared Clipboard > Host To Guest in the VM window.
- **Lesson:** Evaluation licenses: Windows Server 2022 for 180 days, Windows 11 Enterprise for 90 days. Both are free and fine for a lab.
- **Next:** Final cleanup: change the lab passwords, optionally take VM snapshots, add screenshots (with names, IDs and emails blurred), and write the lessons learned in the README.

### 2026-11-24: Documentation, screenshots and architecture diagram

- **Done:**
  - Took screenshots of the finished lab and added them to `docs/images/`, with captions in [screenshots.md](screenshots.md): the OU structure and test users in Active Directory Users and Computers, `CLIENT01` in `OU=Lab\Computers`, the domain sign-in on `CLIENT01`, the Synchronization Service Manager on DC01 (24 runs, all `success`), and `Test User1` in the Entra admin center with "On-premises sync enabled: Yes".
  - Blurred everything that identifies the tenant: the tenant connector name, the immutable ID and email addresses.
  - Drew an architecture diagram of the lab and added it to the README.
  - Saved the machine state of both VMs, so the lab resumes where it stopped.
- **Problem:** DC01 kept locking and sometimes showed a black screen, and Ctrl+Alt+Del from the VirtualBox menu did not always reach the sign-in screen.
- **Fix:** Closing the VM with "Save the machine state" and starting it again brought the sign-in screen back. The password is always typed by hand.
- **Problem:** The Entra user list in the narrow browser pane cut off the UPN column and hid the sync status.
- **Fix:** Opened the user's Properties page instead: the On-premises section shows the sync flag, the last sync time and the on-prem distinguished name.
- **Lesson:** A screenshot of the Synchronization Service Manager and of the on-premises properties of a synced user is better evidence of a working hybrid setup than a bare user list.
- **Next:** Change the lab passwords, then start the next project: the same identity ideas in the cloud.
