# 📡 SSRF (Server-Side Request Forgery)

### 📌 What it is

SSRF allows an attacker to induce the **server-side application** to make requests to an arbitrary domain. Essentially, you are using the vulnerable server as a "proxy" to attack internal systems that you cannot reach directly from the internet.

### 🚩 The "Dead Giveaway" (How to find it)

The "Holy Grail" of SSRF is a **URL within a Parameter**.

**The Test:**

1. **The Observation:** A feature that "fetches" content, like `http://site.com/preview?url=http://google.com`.
2. **The Manipulation:** Change the URL to an internal address: `url=http://127.0.0.1:80` or `url=http://169.254.169.254` (Cloud Metadata).
3. **The Result:** If the server returns internal data (like a local `index.html` or AWS keys), you have SSRF

---

### 🎣 The "Exploitation Path" (OSCP/WGU Strategy)

- [ ] **Step 1: Internal Port Scanning**
    - Use the server to scan itself: `url=http://127.0.0.1:22`, `url=http://127.0.0.1:3306`.
- [ ] **Step 2: Cloud Metadata Exfiltration**
    - **AWS:** `http://169.254.169.254/latest/meta-data/iam/security-credentials/`
    - **Azure:** `http://169.254.169.254/metadata/instance?api-version=2021-02-01`
- [ ] **Step 3: Access Local Files**
    - Try the `file://` protocol: `url=file:///etc/passwd`.