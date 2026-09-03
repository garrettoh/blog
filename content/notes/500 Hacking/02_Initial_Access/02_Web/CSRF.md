# CSRF (Cross-Site Request Forgery)

### Basics

CSRF tricks a **victim's browser** into performing an unwanted action on a different website where they are currently authenticated. Unlike XSS (which steals data), CSRF **executes actions** (e.g., changing a password, deleting an account).

### What to look for

A useful CSRF target is a **sensitive action** (usually a POST request) that does not require a unique CSRF token.

**The Test:**

1. **The Observation:** Find a form (like "Change Email") and look at the request in Burp.
2. **The Check:** Is there a random string like `csrf_token=a83j...`? If **NO**, it is likely vulnerable.
3. **The Proof:** If you can submit the form by only knowing the victim's new email address, you can "force" them to submit it via a hidden form on your own site.

---

### How it differs from related issues

- **XSS:** Steals the cookie.
- **CSRF:** Uses the cookie (without seeing it) to perform an action.
- **SSRF:** Makes the _Server_ do the work.

---

### References

- **[Burp Suite - CSRF PoC Generator](https://portswigger.net/burp/documentation/desktop/tools/engagement-tools/generate-csrf-poc):** (Pro feature, but can be done manually) Generates the HTML to trigger the attack.

---

### Scope note

In **OSCP**, CSRF is usually part of a chain. It may enable an administrative change that exposes another weakness, such as a file upload. Validate the impact after the request succeeds.

### Further reading

- [HackTricks: CSRF](https://book.hacktricks.wiki/en/pentesting-web/csrf-cross-site-request-forgery.html)
