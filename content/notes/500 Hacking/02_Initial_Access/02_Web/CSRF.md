# 🕵️ CSRF (Cross-Site Request Forgery)

### 📌 What it is

CSRF tricks a **victim's browser** into performing an unwanted action on a different website where they are currently authenticated. Unlike XSS (which steals data), CSRF **executes actions** (e.g., changing a password, deleting an account).

### 🚩 The "Dead Giveaway" (How to find it)

The "Holy Grail" of CSRF is a **Sensitive Action** (POST request) that **lacks a unique Token** (CSRF Token).

**The Test:**

1. **The Observation:** Find a form (like "Change Email") and look at the request in Burp.
2. **The Check:** Is there a random string like `csrf_token=a83j...`? If **NO**, it is likely vulnerable.
3. **The Proof:** If you can submit the form by only knowing the victim's new email address, you can "force" them to submit it via a hidden form on your own site.

---

### ⚡ The Difference (Quick Ref)

- **XSS:** Steals the cookie.
- **CSRF:** Uses the cookie (without seeing it) to perform an action.
- **SSRF:** Makes the _Server_ do the work.

---

### 🔗 Payloads & Resources (All The Things)

- **[Burp Suite - CSRF PoC Generator](https://portswigger.net/burp/documentation/desktop/tools/engagement-tools/generate-csrf-poc):** (Pro feature, but can be done manually) Generates the HTML to trigger the attack.

---

### ⚠️ The "Rabbit Hole" Warning

In **OSCP**, if you find CSRF, it is usually part of a chain. You likely need to use it to change an Admin's password so _you_ can log in and find a File Upload vulnerability. Don't stop at the "Success" message—log in and finish the job!