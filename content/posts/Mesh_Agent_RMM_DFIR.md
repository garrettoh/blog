---
title: "Mesh Agent: A story of the random open-source RMM tool"
date: 2026-05-06
author: garrettoh
categories:
  - Security
  - DFIR
tags:
  - RMM
  - Mesh Agent
  - Incident Report
---

# Threat Analysis: MeshAgent Sleeper RMM and Attempted BDE Key Exfiltration

## Initial Information
I wanted to start this off by saying I had never heard of mesh agent previously up until this point. Essentially it is an Open Source RMM tool with a 2010 style UI. It allows for capabilities that many other RMM tools offer which can be used for legitmate purposes aswell as malicious ones. 

This post we're going to go into the attack lifecycle of the attack some lessons learned and key points regarding the initial compromise.

### Diagram of Attack
![](/images/mesh_agent/rmm_diagram.png)
## Attack Timeline & Execution Flow

---

### 1. Initial Access
The initial compromise was a standard domain user whose password was compromised. This connection was created over the remote appliance, and then from there an initial foothold was on the RDS under that users account.


### 2. First-Stage Persistence & C2
After initial compromise they installed the `Mesh Agent` RMM software with their configuration to the `Program Files` Directory. This was installed on all RDS servers in the same directory.
* **Initial C2 IP:** `104.238.129.233`
* **Initial C2 Domain:** `hxxps://vultrusercontent[.]com:http`
* **Uninstall String Identified:** `C:\Program Files\Mesh Agent\MeshAgent.exe -funinstall --meshServiceName="Mesh Agent"`

### 3. Sleeper Deployment & Lateral Movement 
From this point the threat actor laterally moved to a front desk PC whilst slowly mapping out the network.
### 4. Infrastructure Update & Execution
Following the dormancy/slow network mapping period after 2 months which would now be `April 16th 2026`, They added a file in all of the System32 Directories of the RDS Pool and updated the .msh configuration file to point to a new seemingly more active IP `wss://45.13.212[.]7:443`. The attacker queried sessions for local user enumeration and utilized the new binary in the System32 directory to establish a high-privilige session via the new binary. 

### 5. Attempted Exfiltration & EDR Mitigation
Following the upgrade to a higher privilege level the attacker attempted to extract the BitLocker recovery keys and query more domain information
```powershell
Manage-bde.exe -protectors -get C:

Get-Content (Get-PSReadLineOption).HistorySavePath

Get-ChildItem -Path C:\ -Include *.xml,*.config,*.txt,*.ini 
-Recurse -ErrorAction SilentlyContinue | Select-String -Pattern "password"

$searcher = [adsisearcher]"(objectCategory=computer)"; 
$searcher.Filter = "(&(objectClass=computer)(|(name=*SQL*)(name=*DC*)))"; 
$searcher.FindAll() | ForEach-Object { $_.Properties.dnshostname }
```
The attackers objective was to encrypt the contents and extract the information over a TLS and AES IV encrypted tunnel with the new C2 Infrastructure.

To me it looks like more AI slop, what a sad time to be alive.

## Indicators of Compromise (IOCs)

### Network IOCs
* `104.238.129.233`
* `hxxps://vultrusercontent[.]com:http`
* `wss[://]45.13.212[.]7:443`

### File System IOCs
* `C:\Windows\System32\mvtcs.exe` (Renamed Mesh Agent)
* `C:\Program Files\Mesh Agent\MeshAgent.exe`

### SHA256 Hashes
* `893D9B52CCA57395C11C3363D350690767E2F1CF04A01A4600A76C08624AA165`
* `EB1853BF7ADD4D6D053A3BAFCB0D8C2DB4B9C3F71070D0BA32069D99CAA8CECE`
* `044229E938B70AD2BB8403521CFD3B15D4EC518BCA6EC68A6C0CEC963DECD7CD`
* `B7F4CBC43E55774C475AACCA133818C37552ED0923DAC1566241C7CC7DC8F3BB`

### Reference Analysis
`https://www.virustotal.com/gui/file/7e325b6769dcb900f88161e52ba61b18f9f39127f08551638bd652fa2a267833/community`

---

### Personal notes/Information to reach me

P.S if anyone has any really cool samples keep them in your vault, I'm going to setup a communication tunnel on the website rather than just a static blog hugo site. 

So far I'm loving it though

If you want a social for now you can reach out to garrettoh on discord :)

