# omalauncher

This Arch system runs inside an Android launcher, omalauncher; its source is at https://github.com/SimonSchubert/omalauncher, should you need to understand how the launcher works.

It's Arch Linux ARM under proot, not a booted system: you are root already (no sudo needed), and there is no systemd (systemctl, services and timers don't work), no cron, no Docker and no kernel modules. Install packages with pacman or yay, command-line tools with mise. The phone's own storage (/sdcard, Downloads) isn't visible here. xdg-open opens http(s) links in Android's browser; `omarchy-edit <file>` opens a file in the launcher's editor and `omarchy-files [folder]` its file manager; GUI apps (Wayland) open as windows on the launcher.

Home-screen widgets are `.owl` files in ~/.config/omalauncher/widgets, written in a small declarative language documented in README.md there (and docs/ next to it); so are apps for the app drawer (`app "name" { }`) and panels that swiping up or down on home opens (`panel "name" { }`, picked with gestures.swipe-up and gestures.swipe-down in ~/.config/omalauncher/style/style.toml). The app drawer is the panel drawer.owl there: to change the drawer, edit it; .stock-drawer.owl is the drawer as this launcher ships it. Likewise keybar.owl (`keybar "name" { }`) is the terminal key bar over the soft keyboard while typing in a terminal, and .stock-keybar.owl the bar as shipped. Saved files show up on the phone within seconds. After saving, run `owl-check <file>`: it prints the errors and the path of a PNG of the tile or view, drawn with live data; look at it to check the layout. examples/ holds more widgets to learn from or move up to use. Scripts and hooks can set a running widget's state or refresh it with `owl-send <file> set <state> <value>` and `owl-send <file> refresh`.

The launcher's look (theme, background, tile spacing and borders, corners, the system bars' colors, the terminals' font) is ~/.config/omalauncher/style/style.toml; defaults.toml next to it lists every setting with its default and range. Changes show within a second; errors.txt there says what was ignored and why.

Where everything on home is (pages in order, faces, widgets, pinned apps and folders, each tile's cell) is ~/.config/omalauncher/home/layout.toml; edit it to move, resize or pin things or reorder pages. docs/home.md in the widgets folder explains it.

The phone's approximate location, its calendar and the AirPods connected to it are `phone location`, `phone calendar [days]` and `phone airpods` (JSON; `phone --help` says more), where the launcher was allowed them.

## DEV LOGS

Log important development progress for this project with `~/.local/bin/oma-devlogs` (write entries from the project directory). pi and Codex read these rules here; Claude Code reads CLAUDE.md beside this file, which carries the same rules.

- Log important features, implemented changes or fixes, meaningful verification results, and issues that need follow-up. Combine related work into one entry; do not log every reply.
- Keep each entry to 1–3 concise sentences: key changes, actual verification results, and unresolved issues only when relevant. Say when something is unverified; never present plans or assumptions as completed work.
- Skip general Q&A, research, suggestions, trivial edits, routine checks, duplicates, and log maintenance. Exclude secrets and personal data.
- Write entries as `~/.local/bin/oma-devlogs log --project 'omalauncher' 'summary'`, with correct shell quoting. Use the repository or folder name and keep it the same every time; do not repeat it in the summary. Only claim it was recorded after the command succeeds. Check that the command is available and tell the user if writing fails. Do not log this setup or create sample entries.
