## 🛰️ FTP Enumeration (21)
- [ ] **Anonymous Access**
	- [ ] `ftp <IP>` (User: `anonymous` | Pass: `anonymous`)
- [ ] **Binary Mode Check**
	- [ ] Use `binary` command before downloading `.exe` or `.zip` files.
- [ ] **Browser View**
	- [ ] Navigate to `ftp://<IP>` (Check for hidden files like `.ssh/id_rsa`).

**🔥 Common Exploits:**
- **CVE-2010-4221:** ProFTPD exploit.
- **Backdoors:** vsftpd 2.3.4 (The "smiling face" exploit).
- **Write Access:** If you can upload a file, try a PHP reverse shell if port 80 is also open.