# Garrettoh's Research & DFIR Blog

A Hugo site using the [Terminal](https://github.com/panr/hugo-theme-terminal) theme, a Nord-inspired color palette, and custom browse-style layouts for research notes and writeups.

## Local setup

The Terminal theme is a Git submodule. Clone the site recursively:

```powershell
git clone --recurse-submodules https://github.com/garrettoh/blog.git
cd blog
hugo server -D -F
```

If the repository was already cloned without the theme:

```powershell
git submodule update --init --recursive
```

The development site is normally available at `http://localhost:1313/`. `-D -F` includes draft and future-dated content.

Run a production build with:

```powershell
hugo --minify
```

## Where to change things

| What | File or directory |
| --- | --- |
| Site URL, menus, theme options, social links | `hugo.toml` |
| Homepage content | `content/_index.md` |
| Homepage wrapper and social-link placement | `layouts/index.html` |
| GitHub/LinkedIn icon markup | `layouts/partials/social-links.html` |
| Global Nord and responsive layout styles | `static/style.css` |
| Syntax highlighting | `static/syntax.css` |
| Favicon tags | `layouts/partials/extended_head.html` |
| Notes content | `content/notes/` |
| Writeup content and downloads | `content/writeups/`, `static/downloads/writeups/` |

## Shared Notes and Writeups browser

Both `/notes/` and `/writeups/` use the same responsive browse workspace:

- On desktop, the sidebar is fixed and collapsible. The reader centers itself in the viewport space that remains beside it.
- On narrow screens, the sidebar becomes a scrollable “Browse” drawer above the reader.
- Sidebar state is remembered per section for the current browser session.
- Trees and directory cards are generated from Hugo's content hierarchy, so new content appears automatically.
- Long paths, titles, code blocks, tables, images, and very narrow windows are constrained to prevent page-level horizontal overflow.
- The layout respects reduced-motion preferences.

Shared implementation:

- `layouts/partials/browse-workspace-script.html` — collapse/drawer behavior.
- `static/style.css` — final shared rules under “Shared responsive browser for Notes and Writeups.”
- `layouts/partials/notes-sidebar.html` and `notes-tree.html` — Notes navigation.
- `layouts/partials/writeups-sidebar.html` and `writeups-tree.html` — Writeups navigation.

### Adding Notes content

Every browsable folder under `content/notes/` needs an `_index.md`:

```yaml
---
title: "Folder title"
layout: "notes"
---
```

Regular note files should contain normal page front matter and should **not** set `layout: "notes"`. Folder pages use `layouts/section/notes.html`; individual notes use `layouts/notes/single.html`.

When syncing from Obsidian:

1. Put images in `static/` and reference them from the site root, such as `/images/example.png`.
2. Include a useful `title` in front matter.
3. Set `draft: false`, or omit `draft`, when the note should be published.

### Adding Writeups content

Writeups are Hugo branch bundles. Create each archive or challenge as a directory with an `_index.md`. The shared layout reads these optional front-matter fields:

```yaml
---
title: "Challenge title"
layout: "Notes"
overview: "Short description shown beneath the title."
status: "WIP"
eta: "Optional archive target"
---
```

Nested sections automatically appear in both the sidebar and browse cards. Put downloadable artifacts below `static/downloads/writeups/` and link to them with `/downloads/writeups/...` URLs.

## Homepage social links

The homepage currently displays GitHub and LinkedIn. Change their destinations in `hugo.toml`:

```toml
[params.social]
  github = "https://github.com/garrettoh"
  linkedin = "https://www.linkedin.com/in/garrettraeseit"
```

Remove or leave a value empty to hide that profile. Add icon markup for another service in `layouts/partials/social-links.html` and match it with a new setting under `[params.social]`.

## Theme and visual assets

- The main palette is defined near the top of `static/style.css` using CSS variables.
- Hugo uses class-based Chroma output because `[markup.highlight] noClasses = false` is set in `hugo.toml`.
- Favicon files live in `static/favicons/`, with a compatibility copy at `static/favicon.ico`.
- After replacing favicon assets, increment the `?v=1` cache-busting value in `layouts/partials/extended_head.html`.

## Current custom layout files

```text
layouts/
├── index.html
├── notes/single.html
├── section/notes.html
├── writeups/list.html
└── partials/
    ├── browse-workspace-script.html
    ├── extended_head.html
    ├── notes-sidebar.html
    ├── notes-tree.html
    ├── social-links.html
    ├── writeups-sidebar.html
    └── writeups-tree.html
```
