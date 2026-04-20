# Garrettoh's Research & DFIR Blog

This Hugo site uses the **Terminal** theme, heavily customized for a malware research and security engineering workflow.

## Custom Infrastructure

### 1. Favicon System
**Location:** `/static/favicons/` and `/static/favicon.ico`
* **Logic:** The site uses a multi-device favicon set. 
* **Critical:** `favicon.ico` is kept in the root of `/static/` for legacy browser support. PNGs and the manifest are in the subfolder.
* **Cache Busting:** If you update the icon, increment the `?v=1` string in `layouts/partials/extended_head.html`.

### 2. Nord & Syntax Theming
**Files:** `/static/style.css` and `/static/syntax.css`
* **Theme:** Nord Blue Palette.
* **Syntax Highlighting:** Generated via Chroma (`hugo gen chromastyles --style=nord`).
* **Implementation:** `hugo.toml` is set to `noClasses = false`. This ensures the blog uses the external CSS file rather than inlining styles, allowing for easier color tweaks for RE/Assembly snippets.

### 3. Directory Browser (Notes)
**Endpoint:** `/notes/`
To maintain a "CLI/File Explorer" feel for research notes, we use a custom routing system:

* **Directory View (The Folder):** * Handled by `layouts/section/notes.html`.
    * Every sub-folder in `content/notes/` **MUST** contain an `_index.md` with `layout: "notes"` in the front matter.
    * This mimics an `ls -F` output.
* **Note View (The File):**
    * Handled by `layouts/notes/single.html`.
    * **DO NOT** put `layout: "notes"` in individual `.md` files. If you do, the page will render empty because it will try to use the list layout.

## Content Guidelines

### Malware Writeups
Use the standard code fences for highlighting. The `syntax.css` is optimized for:
* C/C++
* x86/x64 Assembly
* Python / Go

### Obsidian Integration
When syncing notes from Obsidian to `content/notes/`:
1. Ensure images are placed in `static/` or use Hugo-compatible relative paths.
2. Ensure front matter contains at least a `title` and `date`.
3. Set `draft: false` to ensure visibility in the directory list.

---
**Technical Note:** If the site doesn't reflect changes, run `hugo server -D -F` to clear the cache and include drafts/future-dated posts.