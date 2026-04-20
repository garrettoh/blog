Using a private key 
```sh
chmod 600 id_ed25519
ssh -i id_ed25519 user@target
```

Cracking passwords
```sh
ssh2john id_ed25519 > hash.hash && sleep 2 && john --wordlist=/usr/share/wordlists/rockyou.txt hash.hash
```