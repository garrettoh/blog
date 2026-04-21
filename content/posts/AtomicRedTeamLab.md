---
title: "Building an IR Lab with Atomic Red Team: Moving Beyond TryHackMe"
date: 2026-04-24
author: garrettoh
categories:
  - Security
  - Lab
tags:
  - PowerShell
  - Atomic Red Team
  - IR
---

Welcome back to my blog today I'm going to be going over something I haven't worked on since I was messing around on TryHackMe for my initial training with `Atomic Red Team`. 

As of right now at my current position most of the team is comprised of standard helpdesk employees and I was hoping I could bridge the gap between security and helpdesk *and hopefully get someone interested into security*. 

This blog will include the more interesting ones that my team worked on *not all*.

## Lab Setup & The "Answer Key" Protocol

To start this out I looked over the documentation *what is this 2004?*......... Then I prompted Gemini to create me some PowerShell scripts that logged the outcome of the techniques so that I could look back on everyone's individual performance

We we're able to get a basic lab I started off by using RegShot and an Autoruns saved data set that we could use to see what the computers current persistence mechanisms were. 

```powershell
# 1. Install Atomic Red Team (if not already present) 
# 2. Don't trust every random IWR | IEX lol 

IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing); Install-AtomicRedTeam -getAtomics 
# 3. Establish the Answer Key Protocol 

New-Item -ItemType Directory -Force -Path C:\temp Start-Transcript -Path "C:\temp\lab_execution.log" -Append 

# 4. (Deploy the scenarios below, then stop the transcript) 
# "SCENARIOxyz.ps1" 

Stop-Transcript

```


## Goal of the Lab

The goals are ordered in terms of most to least importance

1. To bridge the gap between Security and the Helpdesk
2. To foster an environment of learning and growth for my team. 
3. To post on my blog and hopefully guide you! 


## Scenario 1: Hidden Network Shares (T1021.002)

I wanted to start off with something that should be relatively simple with built in windows binaries to see what was happening and I also wanted to see the process my team members took to come to the conclusion. 
### Deployment (Infection)

```powershell
Invoke-AtomicTest T1021.002 -TestNumbers 1 -GetPrereqs -Confirm:$false
Invoke-AtomicTest T1021.002 -TestNumbers 1 -Confirm:$false
"$(Get-Date -Format 'HH:mm:ss') - Deployed Hidden Share (T1021.002)" | Out-File "C:\temp\lab_execution.log" -Append

```




### The Hunt

I wanted the team to solve utilizing `compmgmt.msc` or utilizing `net share` as I suspected they were able to solve this relatively quickly.  
### Cleanup
```powershell
Invoke-AtomicTest T1021.002 -TestNumbers 1 -Cleanup -Confirm:$false

```
## Scenario 2: WMI Event Subscriptions (T1546.003)

This one hit close to home as in my malware development journey this was what my first piece of fileless malware utilized for persistence.

I knew that this one would throw them for a loop and I wanted to start off early with something to show them just how common it is for malware that you deleted with `RevoUninstaller` to still be running or persistent with other techniques. 

I believe this showed my team the work that I do on a daily basis to verify that our infrastructure is secure.

### Deployment (Infection)

```powershell
Invoke-AtomicTest T1546.003 -TestNumbers 2 -GetPrereqs -Confirm:$false 
Invoke-AtomicTest T1546.003 -TestNumbers 2 -Confirm:$false "$(Get-Date -Format 'HH:mm:ss') - Deployed WMI Subscription (T1546.003)
" | Out-File "C:\temp\lab_execution.log" -Append

```

### The Hunt

**Tool:** powershell.exe

Because the WMI doesn't drop a file directly, I hoped they would query the WMI, to see any subscribed events. 

As I was expecting the helpdesk didn't really know where to start and they couldn't find anything *(This is secretly good)* because I can show them that just because they uninstall something, does not always mean its off of the machine. 

Imagine we had a WMI event subscription to reinstall or create a polymorphic service every time the user logs in and if the service had been previously deleted. 

1. The attackers would know were on to them and possibly move to more destructive methods. *(atleast a little lol)*
2. We would tell the client they're good when they're still infected. 

I am happy with the outcome of this task as I believe it taught my team the importance of having a good security program and SOPs in place to make sure communication is delivered to the right channels.

### Cleanup

```powershell
Invoke-AtomicTest T1546.003 -TestNumbers 2 -Cleanup -Confirm:$false

```
## Scenario 3: Hosts File Redirection (T1562.006)

I will start of by explaining the host file, in basic terms it binds a IP address to specific domain(s). 

Attackers can use this if you don't have a ZTNA approach for DNS servers meaning they could point you to look at their infrastructure for DNS resolution to resolve google.com to a fake attacker hosted google etc. 

A lot of my team members were unaware this existed I had believed so it was something interesting I thought that I could show them. 

### Deployment (Infection)

Append a malicious DNS override mapping a legitimate Microsoft domain to a local/loopback address.

```powershell
Invoke-AtomicTest T1562.006 -TestNumbers 1 -GetPrereqs -Confirm:$false 
Invoke-AtomicTest T1562.006 -TestNumbers 1 -Confirm:$false "$(Get-Date -Format 'HH:mm:ss') - Deployed Hosts File Change (T1562.006)" | Out-File "C:\temp\lab_execution.log" -Append

```

### The Hunt

I hoped they would utilize notepad and go to the directory this one was relatively straight forward so they didn't have any issues. 

### Cleanup

```powershell
Invoke-AtomicTest T1562.006 -TestNumbers 1 -Cleanup -Confirm:$false

```

## Scenario 4: Scheduled Task Masquerading (T1053.005)

Scheduled tasks are a staple for persistence. To avoid detection, adversaries disguise their malicious tasks with official-sounding names that blend into the noise of standard Windows background processes.

### Deployment (Infection)

Create a scheduled task named WindowsUpdateManager that executes a standard command prompt shell.

```powershell
Invoke-AtomicTest T1053.005 -TestNumbers 2 -GetPrereqs -Confirm:$false
Invoke-AtomicTest T1053.005 -TestNumbers 2 -Confirm:$false
"$(Get-Date -Format 'HH:mm:ss') - Deployed Masqueraded Task (T1053.005)" | Out-File "C:\temp\lab_execution.log" -Append

```


### The Hunt

Here I hoped they would use SysInternals AutoRuns as that's what I'm going to be quizzing them on at the end of this and was the goal of the lab. 


### Cleanup

```powershell
Invoke-AtomicTest T1053.005 -TestNumbers 2 -Cleanup -Confirm:$false

```

## Scenario 5 Persistence Scenario 

In a lot of the security alerts that I look through these techniques are by far the most common we see registry run keys, services, and scheduled tasks that run malicious instructions. 

I mainly wanted to inform the team on how to handle basic malware or what to look for if they think their computer at home is acting up. 

### Deployment
```powershell
# 1. Setup Logging Path
$LogPath = "C:\temp"
$LogFile = "$LogPath\lab_execution.log"

if (!(Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory | Out-Null }

function Write-LabLog {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $LogFile -Append
}

# 2. Define the techniques
$Techniques = @(
    @{ ID = "T1547.001"; Test = 2 ; Name = "Registry Run Keys" },
    @{ ID = "T1543.003"; Test = 3 ; Name = "New Windows Service" },
    @{ ID = "T1053.005"; Test = 1 ; Name = "Scheduled Task Persistence" }
)

Write-Host "--- Starting Lab Persistence Simulation ---" -ForegroundColor Cyan
Write-LabLog "STARTING NEW LAB SIMULATION"

foreach ($Item in $Techniques) {
    Write-Host "`n[!] Deploying: $($Item.Name) ($($Item.ID))" -ForegroundColor Yellow
    Write-LabLog "Attempting Deployment: $($Item.Name) ($($Item.ID)) - Test #$($Item.Test)"
    
    try {
        # Check and Get Prerequisites
        Invoke-AtomicTest $($Item.ID) -TestNumbers $($Item.Test) -GetPrereqs -Confirm:$false | Out-Null
        
        # Execute the Test
        Invoke-AtomicTest $($Item.ID) -TestNumbers $($Item.Test) -Confirm:$false | Out-Null
        
        Write-LabLog "SUCCESS: $($Item.Name) deployed."
    } catch {
        Write-LabLog "ERROR: Failed to deploy $($Item.Name). Details: $_"
    }
}

Write-Host "`n[+] Simulation Complete. Logs saved to $LogFile" -ForegroundColor Green
Write-LabLog "SIMULATION COMPLETE"

```

### The Hunt

I wanted them to utilize `sysinternals autoruns.exe` this program shows in an easy to view GUI what programs run automatically when the computer starts. 

In most cases this is a great first step of triage and usually my first go too although for most of mine I have scripts to run the cli versions. 

We can use autoruns to utilize platforms such as `virustotal.com` which is a huge repo for malware detections essentially leveraging it into a persistence based EDR *kind of lol but good enough*. 


### Closing notes / Takeaways

I'm glad I did something like this with a non-security focused team such as the helpdesk as I believe bridging the gap between all departments with security is a great first step at a better security posture. 

My team is now trained to get rid of some basic malware and I can nerd out to them a little bit more now :)....

I'm going to keep all of my files in the Random Notes tab on the website under (Project Files) in the home directory.

Thanks for reading and check out my socials :D 