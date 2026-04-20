## Network Discovery
```
nmap -p- -Pn $target -v --min-rate 1000 --max-rtt-timeout 1000ms --max-retries 5 -oN nmap_ports.txt && sleep 5 && nmap -Pn $target -sV -sC -v -oN nmap_sVsC.txt && sleep 5 && nmap -T5 -Pn $target -v --script vuln -oN nmap_vuln.txt
```

rustscan --ulimit 5000 -a $target -- -sC -sV -Pn -oN nmap_full

### Web Content Discovery

#### Directory Brute Forcing

- **Raft Large Directories:** `gobuster dir -u http://$target -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt -t 50 -o gb_dirs.txt`
- **Directory List 2.3 Medium:** `gobuster dir -u http://$target -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 50 -o gb_dirs2.txt`

#### File Discovery

Searching for specific extensions (php, asp, xml, html, js, sql, gz, zip).

- **Common Files:** `gobuster dir -u http://$target -w /usr/share/seclists/Discovery/Web-Content/common.txt -t 50 -x php,asp,xml,html,js,sql,gz,zip -r -o gb_files.txt`
- **Raft Large Files:** `gobuster dir -u http://$target -w /usr/share/seclists/Discovery/Web-Content/raft-large-files.txt -t 50 -x php,asp,xml,html,js,sql,gz,zip -r -o gb_files2.txt`


### Subdomain Enumeration

Using FFUF and IP
`ffuf -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt \ -u http://target.com -H "Host: FUZZ.target.com" -ac`

Using FFUF and DNS
`ffuf -w /usr/share/wordlists/seclists/Discovery/DNS/bitquark-subdomains-top100000.txt \ -u http://FUZZ.target.com -ac`