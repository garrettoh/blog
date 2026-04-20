# 💉 SQL Injection (SQLi)

### 📌 What it is

SQL Injection is a vulnerability where an application improperly handles user input, allowing an attacker to "inject" their own SQL commands into a database query. This can lead to unauthorized data access, data modification, or even full system compromise (RCE).

### 🚩 The "Dead Giveaway" (How to find it)

The classic sign of SQLi is a **Database Error** or a **Change in Page Content** when you input a single quote (`'`).

**The Test:**

1. **The Break:** Append `'` or `"` to a URL parameter (e.g., `id=1'`).
2. **The Result:** If the page returns a "SQL Syntax Error" or if the content disappears (Boolean-based), you've found an injection point.
3. **The Logic Test:** Try `id=1 AND 1=1` (Page loads normally) vs `id=1 AND 1=2` (Page breaks/changes). If this works, it’s 100% vulnerable.

---

### ⚡ The 3 Types (Quick Ref)

1. **In-Band (Union-Based):
    - **How:** Uses the `UNION` operator to combine your results with the original query.
    - **Goal:** Direct data exfiltration. You see the database results right on the screen.
2. **Inferential (Blind):**
    - **How:** You don't see data. You ask the database True/False questions.
    - **Boolean-based:** "If the first letter of the password is 'A', show the 'Welcome' message."
    - **Time-based:** "If the user is 'admin', wait 10 seconds before responding."
3. **Out-of-Band:**
    - **How:** The database makes an external request (like a DNS or HTTP lookup) to your server to "leak" the data.

---

### 🎣 The "Exploitation Path" (OSCP/WGU Strategy)

- [ ] **Step 1: Order By (Find Column Count)**
    - `1' ORDER BY 1--`, `1' ORDER BY 2--` ... until it breaks.
- [ ] **Step 2: Union Select (Find Visible Columns)**
    - `1' UNION SELECT 1,2,3--` (Look for numbers appearing on the page).
- [ ] **Step 3: Fingerprint (Find DB Version)**
    - `1' UNION SELECT 1,@@version,3--` (MySQL/MSSQL)
- [ ] **Step 4: Dump Tables/Users**
    - `1' UNION SELECT 1,group_concat(table_name),3 FROM information_schema.tables--`

---

### 🔗 Payloads & Resources (All The Things)

When you're stuck, use these master lists:

- **[PayloadsAllTheThings - SQL Injection](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/SQL%20Injection):** The industry standard for manual payloads (MySQL, MSSQL, PostgreSQL, Oracle).
- **[Pentestmonkey - SQLi Cheat Sheets](http://pentestmonkey.net/category/cheat-sheet/sql-injection):** Excellent for specific database syntax differences.
- **[HackTricks - SQL Injection]:** Great for advanced bypasses (WAF, filter evasion).

---

### ⚠️ The "Rabbit Hole" Warning

If you are on an OSCP machine and `sqlmap` is forbidden (or you've used your one-time allowance), don't spend 4 hours on a **Time-Based Blind SQLi** manually. If it’s not Union-based or a simple Auth Bypass (`' OR 1=1--`), check if there is a different service (like SMB or FTP) that provides a easier path.