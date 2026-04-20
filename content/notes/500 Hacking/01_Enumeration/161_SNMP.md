## 📡 SNMP Enumeration (161 UDP)
- [ ] **Community String Guessing**
	- [ ] `onesixtyone -c /usr/share/seclists/Discovery/SNMP/common-snmp-community-strings.txt <IP>`
- [ ] **Full Walk (Look for Users/Processes)**
	- [ ] `snmpwalk -v2c -c public <IP> 1.3.6.1.2.1.25.4.2.1.2`
- [ ] **Check for Software Versions**
	- [ ] `snmp-check <IP>`

**🔥 Common Exploits:**
- Extracting cleartext passwords from running process parameters.
- Finding internal network info or hostnames for further pivoting.