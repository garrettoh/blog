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

 Threat Analysis: MeshAgent Sleeper Deployment and Attempted BDE Key Exfiltration

## Executive Summary
This post details a multi-staged intrusion originating from a compromised user account, leading to the deployment of a "sleeper" MeshAgent payload across an RDS environment. The threat actor maintained persistence for over two months, conducting network reconnaissance and lateral movement before attempting to exfiltrate BitLocker (BDE) recovery keys. The final exfiltration phase over an encrypted C2 channel was successfully intercepted and blocked by SentinelOne EDR.

### Diagram of Attack
![](/images/mesh_agent/rmm_diagram.png)
## Attack Timeline & Execution Flow

### 1. Initial Access (2025-12-03)
The intrusion began on December 3, 2025, with the compromise of the account `User\FOSG`. This compromise provided the threat actor with access to the environment's RDS pool (spanning RDS 1 through 4). 

### 2. First-Stage Persistence & C2
Initial persistence was established via a Mesh Agent installation on `frsno-rds-02`. An associated payload named `nfc zip` was identified during this phase. 
* **Initial C2 IP:** `104.238.129.233`
* **Initial C2 Domain:** `hxxps://vultrusercontent[.]com:http`
* **Uninstall String Identified:** `C:\Program Files\Mesh Agent\MeshAgent.exe -funinstall --meshServiceName="Mesh Agent"`

### 3. Sleeper Deployment & Lateral Movement (2026-02-16)
On February 16, 2026, the threat actor installed a new Mesh Agent payload on `FRSNO-ADMIN28`. This agent remained dormant on the device for 2 months and 2 weeks, during which it mapped out the network and prepared for data exfiltration. 

### 4. Infrastructure Update & Execution
Following the dormancy period, the attacker queried the RDS pool (1-4) for existing Mesh Agents. Where found, they replaced the existing legitimate `MSTCS` binary in the `System32` directory with a renamed Mesh Agent binary, `mvtcs.exe` (flagged with 32 detections). This action updated the configuration to point to a new, active C2 infrastructure on `FRSNO-RDS-02`: `wss[://]45.13.212[.]7:443`. The attacker then queried active local sessions for user enumeration. To escalate privileges and execute commands, the attacker utilized the following lateral movement command from the RDS to the Built-in Admin of the `FRSNO-ADMIN28` user:
`mvtcs.exe --connectByUser='S-1-5-21-2909088412-1195962-2846074886-1000'`

### 5. Attempted Exfiltration & EDR Mitigation
Operating with administrative context on `FRSNO-ADMIN28`, the attacker executed the following command to extract BitLocker recovery keys:
`Manage-bde.exe -protectors -get C:`
The objective was to stage the BDE keys and exfiltrate them over the encrypted C2 channel (Mesh IV AES). SentinelOne EDR successfully detected and blocked this exfiltration attempt.

## Indicators of Compromise (IOCs)

### Network IOCs
* `104.238.129.233`
* `hxxps://vultrusercontent[.]com:http`
* `wss[://]45.13.212[.]7:443`

### File System IOCs
* `C:\Windows\System32\mvtcs.exe` (Renamed Mesh Agent, replaced old MSTCS)
* `C:\Program Files\Mesh Agent\MeshAgent.exe`

### SHA256 Hashes (Identified on fresno-rds02 in C:\Program Files\Mesh Agent\)
* `893D9B52CCA57395C11C3363D350690767E2F1CF04A01A4600A76C08624AA165`
* `EB1853BF7ADD4D6D053A3BAFCB0D8C2DB4B9C3F71070D0BA32069D99CAA8CECE`
* `044229E938B70AD2BB8403521CFD3B15D4EC518BCA6EC68A6C0CEC963DECD7CD`
* `B7F4CBC43E55774C475AACCA133818C37552ED0923DAC1566241C7CC7DC8F3BB`

### VirusTotal Results
`https://www.virustotal.com/gui/file/7e325b6769dcb900f88161e52ba61b18f9f39127f08551638bd652fa2a267833/community`
