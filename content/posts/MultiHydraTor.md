---
title: "4 RMMs & Dismantling a Shoddy IAB's Tor Node"

date: 2026-08-04
draft: false
tags:
  - DFIR
  - ThreatHunting
  - Persistence
  - Malware
  - IncidentResponse
  - AccessBroker
categories:
  - Threat Research
---

Hey, it's been a while. Today we're diving into a multi-stage post-compromise investigation that highlights an Initial Access Broker (IAB) handing off access to a buyer. This campaign involved layered C2 infrastructure, subtle persistence mechanisms, and anti-analysis tactics across multiple remote management tools.

The initial alert stemmed from an end-user seeing a visible error message. That single artifact pulled our team down a rabbit hole, eventually revealing a complex chain of initial entry, persistence staging, and access resale.

The error indicated that an automatically starting dependency`Kerncape.vbs`, could not be found in its designated path. 

Remember `Kerncape.vbs`; it becomes central to how the access broker held the door open.

Our Helpdesk team discovered that `Kerncape.vbs` was tied to a rogue WMI event consumer disguised under a native-looking name (`BVTConsumer`). Inspecting active network connections revealed multiple unrecognized process IDs (PIDs) repeatedly establishing and tearing down connections to external IP addresses. That's when Incident Response took over.

---

## Security Investigation

Upon joining the investigation, our primary goal was to trace how the threat actor entered, how they maintained persistence, and how the endpoint was transitioned between actors.

Here is the technical breakdown of the methodology, from initial staging to C2 infrastructure disassembly.

## The Initial Entry: JWrapper & SimpleHelp

Forensic analysis revealed that initial entry occurred via a JWrapper-packaged instance of the SimpleHelp remote access platform (`simplehelper.duckdns.org`). 

The initial access broker used JWrapper simple help remote access to establish an unmonitored foothold. Once inside, the actor ran an obfuscated JScript/VBScript hybrid through `wscript.exe` to inspect normal endpoint communication and evade detection.

The script used a self-decrypting array loop to bypass static analysis. Once de-obfuscated, it modified `HKLM\SOFTWARE\Policies\Microsoft\Windows\System`, setting `EnableSmartScreen` to `0`.

Next, a second-stage dropper spawned a hidden PowerShell process executing a payload placed directly in `System32`:

```powershell
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\Windows\System32\download.ps1`
```

This script called out over non-standard port 8404 to fetch a secondary installer (`InstallDr_o.msi`), while abusing `iexpress.exe` to proxy cabinet files out to staging infrastructure, bypassing standard application whitelisting.

## The Access Broker Hand-Off: Tor Beacons & WMI Persistence

Once the initial access broker established entry, their primary objective was to install redundant persistence before selling the victim system on the dark web. 

To retain control even if the buyer remediated the initial entry vector, the broker deployed a local Tor proxy beacon (`a.exe` / `mqsvc.exe`) configured to reach an onion-service C2:

AGENT_RELAY_HOST: gy4mou62xing74czn6xwirpv3kxg23rjmzyd4jsy42eujnqca64fdgqd.onion  
AGENT_RELAY_PORT: 7980  
AGENT_TOKEN: [REDACTED]

To maintain persistent execution of this Tor beacon across reboots (including Safe Mode), the broker dropped `KernCape.vbs` and bound it to an `ActiveScriptEventConsumer` masquerading as a legacy Microsoft Built-in Verification Test (`BVTConsumer`). 

> **Key Insight:** The Tor beacon was the specific component responsible for implanting the WMI persistence. This allowed the access broker to guarantee persistent access to the host even post-sale.

After this persistence layer was locked down, the access broker sold system access to a buyer. The buyer subsequently installed their own C2 client: ScreenConnect (`172.93.215.142`).

## Safe Mode Triage & The Persistence Hydra

When the endpoint was booted into Safe Mode with Networking to isolate the activity, the threat actor's redundancy kicked in immediately. An anomalous `notepad.exe` spawned, initiating an outbound TCP connection to a remote C2 node while process metrics for `lsass.exe` spiked due to targeted memory scraping.

Through registry and forensic inspection, we mapped the full hand-off chain:

1. **The Broker's Initial Entry:** JWrapper / SimpleHelp framework (`simplehelper.duckdns.org`).
2. **The Broker's Persistent Anchor:** Local Tor Proxy agent masquerading as `mqsvc.exe`, tied directly to the `BVTConsumer` WMI trigger (`KernCape.vbs`).
3. **The Buyer's Access Engine:** ScreenConnect client installed post-sale (`172.93.215.142`), leaving credential provider hooks in `HKLM\...\Credential Providers`.
4. **The Secondary Backup:** A Nezha monitoring agent deployed into user AppData (`C:\Users\*\AppData\Local\Teams-ms\nezha-agent.exe`) pointing to `data.mymarketplacehub.net`.

## Remediation and Neutralization

Severing this multi-stage hand-off required eradicating the access broker's underlying persistence alongside the buyer's active access points:

1. **Network Isolation:** Quarantined the host to sever the Tor relay loop, ScreenConnect session, and Nezha telemetry.
2. **Process Eviction:** Terminated rogue PIDs (`notepad.exe`, `mqsvc.exe`, `nezha-agent.exe`).
3. **WMI Purge:** Removed the malicious `BVTConsumer` instance from `root\subscription` to prevent `KernCape.vbs` re-execution.
4. **Account Lockdown:** Disabled the backdoored local account `mme`.
5. **Registry & Service Cleanup:** Purged ScreenConnect credential provider hooks, removed the JWrapper service entry, and deleted path artifacts (`\ig\`, `\igolnik\`, and `Teams-ms`).

---

## Comprehensive Indicators of Compromise (IoCs)

### Network Infrastructure

| Indicator Type | Value | Context |
| :--- | :--- | :--- |
| Tor C2 (`.onion`) | `gy4mou62xing74czn6xwirpv3kxg23rjmzyd4jsy42eujnqca64fdgqd.onion` | Access broker Tor relay destination |
| Outbound Port | `7980` | Local Tor proxy relay port |
| Outbound Port (ScreenConnect Default) | `8404` | Secondary payload staging port |
| Domain | `simplehelper.duckdns.org` (`103.219.153.206`) | Initial Entry (JWrapper / SimpleHelp) |
| IP Address | `172.93.215.142` | Buyer C2 (ScreenConnect Client) |
| Domain | `data.mymarketplacehub.net` (`188.227.197.233`) | Backup Nezha agent C2 |
| IP Address | `67.43.48.21` | Rogue `notepad.exe` C2 connection |

---

### File System & Binaries

| File Name / Path | SHA-256 Hash | Description |
| :--- | :--- | :--- |
| `C:\ProgramData\ig\a.exe` | `E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855` | Access broker Tor Proxy Client Binary |
| `C:\tools\kernrate\KernCap.vbs` | N/A | Stager script executed via broker WMI persistence |
| `...\Teams-ms\nezha-agent.exe` | `B373DB878A8E5B23431730430EF25C38F425CD8088D276F7A70C66557EACD68B` | Backup Nezha monitoring agent |
| `C:\Windows\Temp\InstallDr_o.msi` | Context Dependent | Secondary stage installer payload |

---

### Host & Registry Artifacts

| Artifact Type | Path / Value | Context |
| :--- | :--- | :--- |
| WMI Consumer | `BVTConsumer` | Broker's `ActiveScriptEventConsumer` persistence |
| Process | `mqsvc.exe` | Masqueraded Tor proxy client process |
| Registry | `HKLM\...\Credential Providers` | Buyer ScreenConnect persistence hooks |
| Registry | `HKLM\SOFTWARE\Policies\...\System` | `EnableSmartScreen` set to 0 |


----

Key Takeaways & Personal Notes:
----

I wanted to say I thought it was interesting that the IAB maintained access after we can assume they sold access to the other cybercriminals.

One thing I also found interesting is that `KernCape.vbs` is mispelled as the common built in Windows default vbs file that is in `C:\tools\` which in this case does not exist.

The actual spelling is `Kerncap.vbs` and it's typically used for low-level kernel troubleshooting/debugging. 

I plan to release more of these blogs following DEFCON and hope you continue to enjoy reading these :)
