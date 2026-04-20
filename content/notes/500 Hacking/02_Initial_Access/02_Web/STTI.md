# 🏗️ SSTI (Server-Side Template Injection)

### 📌 What it is

SSTI occurs when an application embeds user input directly into a **Template Engine** (like Jinja2, Twig, or Mako) instead of passing it as data. Template engines are designed to execute code to generate dynamic HTML; if you can inject into them, you aren't just changing text—you are running code on the server.

### 🚩 The "Dead Giveaway" (How to find it)

The "Holy Grail" of SSTI is **Mathematical Reflection**. You send a math problem in the template's syntax, and the server returns the **answer**.

**The Test:**

1. **Input:** `{{7*7}}` or `${7*7}`
2. **Result:** If the page renders **49**, you have confirmed SSTI.
3. **The Fingerprint:** Try different syntaxes to see which engine is running:
    - `${7*7}` -> `${7*7}` (No change? Try `{{7*7}}`)
    - `{{7*'7'}}` -> `7777777` (Likely **Jinja2** or **Twig**)
    - `{{7*'7'}}` -> `49` (Likely **Mako**)

---

### ⚡ The 3 Most Common Engines (Quick Ref)

1. **Jinja2 (Python/Flask/Django):**
    - **Syntax:** `{{ ... }}`
    - **Exploit Goal:** Access the `__mro__` or `__subclasses__` to find the `os` module and run system commands.
2. **Twig (PHP/Symfony):**
    - **Syntax:** `{{ ... }}`
    - **Exploit Goal:** Use the `_self` or `registerUndefinedFilterCallback` to execute `exec()` or `system()`.
3. **Java (Thymeleaf/FreeMarker):**
    - **Syntax:** `${ ... }`
    - **Exploit Goal:** Use Java Reflection to access `java.lang.Runtime` for RCE.

---

### 🎣 The "Exploitation Path" (OSCP/WGU Strategy)

- [ ] **Step 1: Identify the Engine**
    - Use the [SSTI Decision Tree](https://www.google.com/search?q=https://portswigger.net/web-security/images/template-injection-decision-tree.png) to confirm if it's Jinja, Twig, or Smarty.
- [ ] **Step 2: Read Local Files**
    - **Jinja2 Example:** `{{ get_flashed_messages.__shell__.open('/etc/passwd').read() }}`
- [ ] **Step 3: Gain RCE (Remote Code Execution)**
    - **Jinja2 (Standard):** `{{ self.__init__.__globals__.__builtins__.__import__('os').popen('id').read() }}`
    - **Twig:** `{{_self.env.registerUndefinedFilterCallback("system")}}{{_self.env.getFilter("id")}}`

---

### 🔗 Payloads & Resources (All The Things)

- **[PayloadsAllTheThings - SSTI](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Template%20Injection):** The most comprehensive list of payloads for every engine (Python, PHP, Java, Ruby).
- **[HackTricks - SSTI](https://www.google.com/search?q=https://book.hacktricks.xyz/pentesting-web/ssti-server-side-template-injection):** Excellent breakdown of how to "climb" the Python object tree to reach RCE.
- **[Tplmap](https://github.com/epinna/tplmap):** The "SQLmap" of SSTI. **Warning:** Use cautiously in OSCP (check current exam rules on automated exploitation tools).

---

### ⚠️ The "Rabbit Hole" Warning

If you see `{{ ... }}` and your math doesn't work, check for **Client-Side Template Injection (CSTI)**. If the site uses **AngularJS** or **Vue.js**, the "math" might only work in your browser, not on the server. In that case, treat it like **XSS**, not RCE.