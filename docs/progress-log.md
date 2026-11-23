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
  - Started the download of the Windows 11 Enterprise Evaluation ISO for the domain-joined client (free evaluation).
- **Problem:** The Microsoft Evaluation Center asks for a registration form before each ISO download.
- **Fix:** Filled in the form once per product; marketing opt-ins left unchecked.
- **Next:** Install VirtualBox, create the Windows Server 2022 VM (about 2 GB RAM, disk on D:), install the OS, set a static IP.
