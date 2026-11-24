# Screenshots

Evidence for the lab results. Tenant names, emails and IDs are blurred. Image files live in `docs/images/`.

## Architecture

![Hybrid identity lab architecture](images/06-architecture-diagram.png)

## 1. On-premises Active Directory (DC01)

OU structure `OU=Lab` with the child OUs Admins, Computers, Groups and Users, and the three test users in `OU=Users`:

![Active Directory Users and Computers: OU=Lab with Test User1-3](images/02-dc01-aduc-ou-lab.png)

## 2. Domain-joined client

`CLIENT01` appears in `OU=Lab\Computers` after the domain join:

![CLIENT01 in the Computers OU](images/03-dc01-client01-in-computers-ou.png)

## 3. Domain sign-in on CLIENT01

Signed in as `lab\test.user1` on `CLIENT01`, domain `lab.local`, with the NAT address and the internal lab address `10.10.10.20`:

![whoami and ipconfig on CLIENT01](images/07-client01-domain-login.png)

## 4. Synchronization on DC01

Synchronization Service Manager on DC01: 24 runs, every Import, Delta Synchronization and Export run on the `lab.local` and tenant connectors finished with status `success` (the tenant connector name is blurred):

![Synchronization Service Manager, all runs successful](images/04-dc01-sync-service-manager.png)

## 5. The same user in Microsoft Entra ID

`Test User1` in the Entra admin center: "On-premises sync enabled: Yes", last sync time, distinguished name `CN=Test User1,OU=Users,OU=Lab,...` and SAM account name `test.user1`. The account came from the on-prem directory through Entra Connect, not from the portal (immutable ID blurred):

![Test User1 on-premises properties in Entra ID](images/05-entra-test-user1-onprem-sync.png)
