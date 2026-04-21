Test ITF
---
```powershell
# 1. Setup Logging
$LogFile = "C:\temp\lab_execution.log"
if (!(Test-Path "C:\temp")) { New-Item -Path "C:\temp" -ItemType Directory | Out-Null }

function Write-LabLog {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $LogFile -Append
}

# 2. Define the IT-focused techniques
$Techniques = @(
    @{ ID = "T1098"; Test = 1 ; Name = "Account Manipulation (Add User to Admin Group)" },
    @{ ID = "T1562.001"; Test = 11 ; Name = "Disable Security Tools (Proxy/Firewall Registry)" },
    @{ ID = "T1547.009"; Test = 1 ; Name = "Shortcut Modification (LNK Hijacking)" }
)

Write-Host "--- Starting IT Essentials Lab Simulation ---" -ForegroundColor Cyan
Write-LabLog "STARTING IT ESSENTIALS SIMULATION"

foreach ($Item in $Techniques) {
    Write-Host "`n[!] Deploying: $($Item.Name)" -ForegroundColor Yellow
    Write-LabLog "Deploying: $($Item.Name) ($($Item.ID))"
    
    try {
        # Get Prereqs (Required for downloading dummy LNK files or tools)
        Invoke-AtomicTest $($Item.ID) -TestNumbers $($Item.Test) -GetPrereqs -ErrorAction SilentlyContinue | Out-Null
        
        # Run the Test
        Invoke-AtomicTest $($Item.ID) -TestNumbers $($Item.Test) -Confirm:$false | Out-Null
        
        Write-LabLog "SUCCESS: $($Item.ID) Test $($Item.Test) deployed."
    } catch {
        Write-LabLog "ERROR: Failed $($Item.ID). $_"
    }
}

Write-Host "`n[+] Simulation Complete. Have the team check Local Admins, Proxy settings, and Desktop Shortcuts." -ForegroundColor Green
```


Cleanup
```powershell
$LogFile = "C:\temp\lab_execution.log"
Write-Host "--- Cleaning Up IT Essentials Lab ---" -ForegroundColor Cyan
Write-LabLog "CLEANUP STARTING"

$CleanupList = @("T1098", "T1562.001", "T1547.009")

foreach ($ID in $CleanupList) {
    Invoke-AtomicTest $ID -Cleanup -Confirm:$false | Out-Null
    Write-LabLog "Cleaned up: $ID"
}

Write-Host "[+] Lab restored to clean state." -ForegroundColor Green
Write-LabLog "CLEANUP COMPLETE"
```

Test Advanced IT
---
```powershell
# 1. Setup Logging
$LogFile = "C:\temp\lab_execution.log"
if (!(Test-Path "C:\temp")) { New-Item -Path "C:\temp" -ItemType Directory | Out-Null }

function Write-LabLog {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $LogFile -Append
}

# 2. Define the "Advanced IT" techniques
$Techniques = @(
    @{ ID = "T1574.007"; Test = 1 ; Name = "Path Environment Variable Hijack" },
    @{ ID = "T1176"; Test = 1 ; Name = "Browser Extension Injection" },
    @{ ID = "T1021.002"; Test = 1 ; Name = "Malicious Network Share Creation" }
)

Write-Host "--- Starting Advanced IT Lab Simulation ---" -ForegroundColor Cyan
Write-LabLog "STARTING ADVANCED IT SIMULATION"

foreach ($Item in $Techniques) {
    Write-Host "`n[!] Deploying: $($Item.Name)" -ForegroundColor Yellow
    Write-LabLog "Deploying: $($Item.Name) ($($Item.ID))"
    
    try {
        # Check/Get Prereqs
        Invoke-AtomicTest $($Item.ID) -TestNumbers $($Item.Test) -GetPrereqs -Confirm:$false | Out-Null
        
        # Run Test
        Invoke-AtomicTest $($Item.ID) -TestNumbers $($Item.Test) -Confirm:$false | Out-Null
        
        Write-LabLog "SUCCESS: $($Item.ID) deployed."
    } catch {
        Write-LabLog "ERROR: Failed $($Item.ID). $_"
    }
}

Write-Host "`n[+] Simulation Complete. Check Environment Variables, Browser Extensions, and Network Shares." -ForegroundColor Green
```


Cleanup
```powershell
$CleanupList = @("T1574.007", "T1176", "T1021.002")
foreach ($ID in $CleanupList) {
    Invoke-AtomicTest $ID -Cleanup -Confirm:$false | Out-Null
}
Write-Host "[+] Lab restored." -ForegroundColor Green
```



Test Persistence
---
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

Cleanup
```powershell
Write-Host "--- Cleaning Up Lab Environment ---" -ForegroundColor Cyan

Invoke-AtomicTest T1547.001 -TestNumbers 2 -Cleanup -Confirm:$false
Invoke-AtomicTest T1543.003 -TestNumbers 3 -Cleanup -Confirm:$false
Invoke-AtomicTest T1053.005 -TestNumbers 1 -Cleanup -Confirm:$false

Write-Host "[+] All artifacts removed." -ForegroundColor Green
```

Test Hidden share
---
```powershell
# Deploy Lab 6
Invoke-AtomicTest T1021.002 -TestNumbers 1 -GetPrereqs -Confirm:$false
Invoke-AtomicTest T1021.002 -TestNumbers 1 -Confirm:$false
"$(Get-Date -Format 'HH:mm:ss') - Deployed Hidden Share (T1021.002)" | Out-File "C:\temp\lab_execution.log" -Append
```

```powershell
Invoke-AtomicTest T1021.002 -TestNumbers 1 -Cleanup -Confirm:$false
```
Test WMI Event Subscription
---
```powershell
# Deploy Lab 7 
Invoke-AtomicTest T1546.003 -TestNumbers 2 -GetPrereqs -Confirm:$false Invoke-AtomicTest T1546.003 -TestNumbers 2 -Confirm:$false "$(Get-Date -Format 'HH:mm:ss') - Deployed WMI Subscription (T1546.003)" | Out-File "C:\temp\lab_execution.log" -Append 
```

```powershell
Invoke-AtomicTest T1546.003 -TestNumbers 2 -Cleanup -Confirm:$false
```
Test Host File Redirection
---
```powershell
# Deploy Lab 8 
Invoke-AtomicTest T1562.006 -TestNumbers 1 -GetPrereqs -Confirm:$false Invoke-AtomicTest T1562.006 -TestNumbers 1 -Confirm:$false "$(Get-Date -Format 'HH:mm:ss') - Deployed Hosts File Change (T1562.006)" | Out-File "C:\temp\lab_execution.log" -Append
```

```powershell
Invoke-AtomicTest T1562.006 -TestNumbers 1 -Cleanup -Confirm:$false
```
Test Scheduled Task Masquerading
---
```powershell
# Deploy Lab 9
Invoke-AtomicTest T1053.005 -TestNumbers 2 -GetPrereqs -Confirm:$false
Invoke-AtomicTest T1053.005 -TestNumbers 2 -Confirm:$false
"$(Get-Date -Format 'HH:mm:ss') - Deployed Masqueraded Task (T1053.005)" | Out-File "C:\temp\lab_execution.log" -Append
```

```powershell
Invoke-AtomicTest T1053.005 -TestNumbers 2 -Cleanup -Confirm:$false
```
Test Service ImagePath Hijack
---
Deploy

```powershell
# Deploy Lab 10
Invoke-AtomicTest T1543.003 -TestNumbers 1 -GetPrereqs -Confirm:$false
Invoke-AtomicTest T1543.003 -TestNumbers 1 -Confirm:$false
"$(Get-Date -Format 'HH:mm:ss') - Deployed Service Hijack (T1543.003)" | Out-File "C:\temp\lab_execution.log" -Append
```


```powershell
Invoke-AtomicTest T1543.003 -TestNumbers 1 -Cleanup -Confirm:$false
```