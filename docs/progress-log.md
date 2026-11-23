# Progress log

One entry per work session: what I did, what broke, how I fixed it. Add screenshots to a `docs/images/` folder and link them here (blur tenant names, IDs and emails first).

## Template

### YYYY-MM-DD: short title

- **Done:**
- **Problem:**
- **Fix:**
- **Next:**

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
