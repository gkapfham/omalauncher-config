# omalauncher setup

This repository is the whole configuration of omalauncher on this phone: the home layout, the face, every widget, the
drawer, the swipe-down controls, the terminal key bar, the style, the hand-installed fonts, and the pi setup around them.
It is kept in git and uploaded to Google Drive so a new phone, a reinstall, or a bad edit costs nothing.

It also carries the tools that make that true: `save.sh`, `restore.sh`, `drive.js`, `owl-config`, and the **backup** and
**restore** tiles/app. Read **Backup and restore** below before changing anything important.

---

## At a glance

| | |
| --- | --- |
| Phone | Pixel 9a running Arch Linux ARM inside omalauncher |
| Launcher | omalauncher 0.17.0, OWL language level 17 |
| Theme | `vitamin` |
| Wallpaper | `image-1793586720734.png` from the `vitamin` theme's backgrounds |
| Font | `Maple Mono NF`, terminal `Maple Mono NF:style=SemiBold` |
| Grid | 8 columns, about 15 rows |
| Swipe up | `drawer.owl` — the app drawer |
| Swipe down | `controls.owl` — toggles, volume, battery, screen, media, alarm, notifications |
| Home | a face, then six pages of tiles, then a maintenance page |
| Backups | local git plus Google Drive → `omalauncher-backups`, newest 10 |

---

## What is in this repository

| here | lives at |
| --- | --- |
| `omalauncher/widgets/*.owl` | `~/.config/omalauncher/widgets/` — widgets, the face, the drawer, the controls panel, the key bar, the backup app |
| `omalauncher/style/style.toml`, `defaults.toml` | `~/.config/omalauncher/style/` — theme, background, tiles, terminal font, gestures |
| `omalauncher/home/layout.toml` | `~/.config/omalauncher/home/` — pages, faces, every tile and its cell |
| `omalauncher/agent` | `~/.config/omalauncher/agent` — the default coding agent (`pi`) |
| `omarchy/themes/`, `omarchy/backgrounds/` | `~/.config/omarchy/` — the `vitamin` theme and wallpapers |
| `fonts.tar.zst` | `~/.local/share/fonts/` — the hand-installed Maple Mono NF family, zstd-compressed |
| `pi/agent/extensions/`, `settings.json`, `keybindings.json`, `open-tui.json`, `themes/` | `~/.pi/agent/` — pi's setup |
| `pi/agent/skills/google-workspace/` | `~/.pi/agent/skills/` — the OAuth + Google APIs skill the agenda uses |
| `AGENTS.md` | `~/AGENTS.md` — what pi reads about this phone |
| `bin/owl-agenda` | `~/.local/bin/` — the calendar CLI behind `30-agenda.owl` |
| `bin/owl-mail` | `~/.local/bin/` — the Gmail CLI behind `20-mail.owl` |
| `bin/owl-config` | `~/.local/bin/` — the backup/restore CLI behind the tiles and the app |
| `bin/owl-usage` | `~/.local/bin/` — today's pi spend, read from pi's session logs, behind `40-pi-spend.owl` |
| `bin/omarchy-sshd` | `/usr/local/bin/` — starts sshd on port 2222 for `sshd.owl` |
| `drive.js`, `drive-backup.sh` | the Google Drive side of the backup |
| `save.sh`, `restore.sh` | snapshot to git, and apply a snapshot |

Deliberately **not** saved:

- `~/.pi/agent/auth.json` (API keys) and `~/.pi/agent/sessions/` (conversations);
- Google OAuth tokens in `~/.pi/google-workspace/tokens/`;
- widget `persist` state and `secret` values — the launcher keeps those in Android app data, not in files;
- caches: `widgets/.preview`, `.check`, `.errors`, `.inbox`, `.market*.json`, `.removed/`, and `.stock-*` files;
- Android apps and their data, icon caches, and the launcher APK itself.

---

## Style — `style/style.toml`

The file follows the Omarchy look. `defaults.toml` next to it lists every setting, its default and its range; when
something here is ignored, `style/errors.txt` says why.

- `theme = "vitamin"` — an Omarchy theme directory under `~/.config/omarchy/themes/vitamin`.
- `background = "image-1793586720734.png"` — from `~/.config/omarchy/backgrounds/vitamin/`.
- `font = "Maple Mono NF"` — all launcher and widget text.
- `[home] columns = 9` — the grid is nine cells wide, not the stock six. Every tile's width below is in these cells.
- `[home] single-page = true` — only matters on foldables; it does not collapse the pages.
- `[widgets] opacity = 0.93`, `border-width = 0` — the tiles' glass without a border.
- `[icons] monochrome = true` — app icons are silhouettes in the theme's foreground.
- `[corners] scale = 1` — round, stock-Android corners. Omarchy's own default is square (`0`).
- `[status-bar] shown = false` — the Android status bar is hidden on home; the face has its own bar.
- `[terminal] font = "Maple Mono NF:style=SemiBold"` — the font inside terminal windows and terminal tiles.
- `[gestures] swipe-up = "drawer.owl"`, `swipe-down = "controls.owl"`.

The theme's colours give every widget `accent`, `foreground`, `muted`, `background`, `surface`, `red`, `green`,
`yellow`, `orange`, `blue`, `cyan`, `magenta` and the rest, so a theme change retints everything.

---

## Home — `home/layout.toml`

`layout.toml` is home, in order. `x` and `y` count cells from the top left; `w` and `h` are the tile's size. The phone
rewrites the file when a tile is moved; edits here show within a second, and `home/errors.txt` says what was ignored.

| Page | What is on it |
| --- | --- |
| first | the **omarchy** face (a whole page left of the first tile page) |
| page 2 | quick settings 8×2 at (0,0); agenda 8×12 at (0,2); sshd 8×1 at (0,14) |
| page 3 | mail 8×15 at (0,0) |
| page 4 | notifications 8×5 at (0,0); today 8×6 at (0,5); now-playing 8×4 at (0,11) |
| page 5 | storage 8×8 at (0,0); backup 4×5 at (0,8); restore 4×5 at (4,8); recent apps 8×2 at (0,13) |
| page 6 | speedtest 8×10 at (0,0); netbird 8×5 at (0,10) |
| page 7 | hacker news 8×15 at (0,0) |
| page 8 | pi spend 8×5 at (0,0); maintenance 8×3 at (0,5) |

Pages 2 to 7 fill all 15 rows. Page 8 is the newest one and has rows to spare; every tile can be dragged anywhere, and
each file declares a starting size of its own.

---

## The face — `market-face-simonschubert-omarchy.owl`

An Omarchy session as a whole home page: a workspace bar, tiled glass windows, fastfetch, and the phone's apps.

- **Workspace 1 — desktop.** Fastfetch with user@host, OS, host, kernel, uptime, package count, shell, launcher version,
  theme, CPU, memory and battery; the theme's 16-colour palette; and a **recent apps** grid.
  Recent apps show **icons only** — the names were removed on purpose.
- **Workspace 2 — apps.** The full app list with icons and names.
- **Workspace 3 — agents.** The coding agents installed in Linux (currently `pi`), with a Manage link. There is **no
  notifications workspace**; it was removed.
- **Bar.** Workspace numbers 1–3, weekday/date/time, DND, and battery percentage with charging/low colours.
- **Media strip.** When something plays, the bar adds artist/app, title, and a play/pause tap.
- **Sources.** `android.device`, `system`, `battery`, `modes`, `media`, `apps`, `recent`, `agents`; one optional hourly
  Linux `cmd` for the OS name, pacman package count and `$SHELL`.
- **Taps.** Workspace numbers switch views; the ● opens the style screen; the gear opens launcher settings.

The face is a store file. Its two local changes are the icon-only recents and the removed notifications pane. A store
update could overwrite them; the backup keeps this edited version.

---

## The widgets

### `30-agenda.owl` — Google Calendar
Page 2, 9×13. The next days of every selected Google calendar, today first. `owl-agenda json` runs every 10 minutes (60 s
timeout), so the tile does not need pi running. Tapping opens a two-week screen; pull down to refresh. With no account,
it shows the `owl-agenda login` command. Requires `python` and `nodejs`.

### `market-rat0sh1-quick-settings.owl` — quick settings
Page 2, 9×2. Wi-Fi, mobile data, torch, media, Do Not Disturb and btop in one row of square tiles. Wi-Fi, data, torch and
DND are read from Android; the tiles open the relevant Android panel where a launcher may not switch them. Long-press
torch for a brightness slider, long-press DND for its levels. Requires `btop`; it fetches JetBrains Mono and Nerd Font
symbols from GitHub, so offline it falls back to plain glyphs.

### `10-today.owl` — date and weather
Page 3, 9×5. Date, current conditions, feels-like, high/low, and the next days, with sun times. Weather comes from
Open-Meteo and the location from `ipwho.is` by IP; tap to set a city instead. Tapping opens the 24-hour, 3-day, wind, UV,
sun and moon screen; °C/°F switch on the tile. Text is in English (`strings { en { … } }`); no Linux needed.

### `market-rcrohmana-storage.owl` — storage
Page 3, 9×7. A treemap of the Linux folders two levels deep, the phone's data partition free/used, and the caches that are
safe to clean, with per-item and **Clean** buttons. Android's own storage (photos, apps) is not visible from Linux, so the
folders are Arch's. It scans hourly (120 s timeout) and detaches cleaning with `setsid`. Requires `coreutils`,
`findutils`, `util-linux`, `gawk`, `sed`, `jq` and `pacman-contrib`.

### `market-reymarch995-now-playing.owl` — now playing
Page 3, 9×3. Album art, title/artist, a seek bar, and previous/play/next. It uses `android.media`, so it needs the same
notification access as media widgets. The title scrolls when it does not fit; with nothing playing it says so.

### `sshd.owl` — SSH into the phone
Page 2, 8×1. Whether sshd runs, the address to reach it on (the NetBird tunnel first, then Wi-Fi) and the port, with a
tap to start it. `/usr/local/bin/omarchy-sshd` starts it on **2222**, because Android won't let the launcher's Linux bind
a port below 1024, and with passwords off: only keys in `~/.ssh/authorized_keys` get in. While that file is empty the tile
says `no key` and a tap opens it in the editor, so there is a way in before the first key is pasted. The server is
started again by the tile if it ever goes, and `omarchy-sshd stop` stops it. Requires `openssh` and `iproute2`.

### `backup-tile.owl` — backup
Page 4. Shows the current backup state, the newest saved setup's date/time/size, and a **back up** button; the tile's
screen has **back up now**, **refresh list**, and the same saved-setups list as the app.

### `restore-tile.owl` — restore
Page 4. Shows the newest saved setup and a **restore** button; the screen has **check newest**, **refresh list**, the full
saved-setups list, and **undo last restore** after a restore. Restoring is checked and can roll itself back — see
**Backup and restore**.

### `40-pi-spend.owl` — pi spend
Page 8, 8×5. What pi cost today: dollars, tokens and sessions, the last seven days as a sparkline, the most-used model,
and whether pi is running now. `owl-usage` reads pi's own session logs (`~/.pi/agent/sessions`), adding up the cost and
tokens pi recorded for each message by the phone's local day — no API key, no network, about a quarter of a second for a
week of logs. When `pi-quotas` is set up for OpenCode Go (`~/.config/opencode/opencode-quota/opencode-go.json` with a
workspace id and auth cookie), the tile also shows the 5-hour and weekly quota windows as bars. A failed run keeps the
last good numbers. Requires `python`; tapping opens the agents screen.

### `45-maintenance.owl` — maintenance
Page 8, 8×3. Four rows that would otherwise go unnoticed: pending Arch updates (counted against a private copy of the
databases in `/tmp`, so pacman's lock is never taken), Android's system updates, setup files changed but not saved yet,
and whether the last backup to Drive worked. Green at zero, yellow above it, red for a failure. Each row acts: Arch opens
`pacman -Syu` in a terminal, Android opens the launcher's settings, config runs `save.sh`, and backup runs
`owl-config save` (which also refreshes `status.json`). Requires `git`, `pacman` and `coreutils`.

### `backup.owl` — backup & restore app
In the app drawer. The same backup/restore screen as the tiles, for when home is not showing. It is an OWL app, not part
of the launcher APK.

---

## Panels and gestures

### `drawer.owl` — swipe up
The app drawer: your apps in one column, search as you type in the prompt bar, work-profile tab, folders, rename, hide,
and a long-press menu for pin/info/uninstall/shortcuts/settings. The gear opens launcher settings and carries the update
dot. It reads `android.drawer` and `android.agents`. The stock version is `.stock-drawer.owl`; the launcher falls back to
it if this one is missing or broken, so the drawer cannot lock you out.

### `controls.owl` — swipe down
A control centre:

- **toggles** — torch (long-press for brightness), Do Not Disturb (long-press for priority/alarms/total silence), sound.
- **levels** — media volume.
- **battery** — percentage, bar, charging/plugged/on-battery, temperature, watts, current, and time to full while charging.
- **screen** — brightness percentage and bar, with `auto` when auto-brightness is on. Brightness is **read-only** for a
  launcher; tapping opens Android's display settings.
- **media** — art, title, artist, and previous/play/next.
- **next alarm** — the next alarm and when it is.
- **notifications** — non-ongoing notifications, with snooze 1 h, action buttons, reply, clear, swipe/long-press dismiss,
  and an explicit `none` when empty.

Android's notification source deliberately leaves out ongoing/foreground notifications (music, downloads, charging), so
those never appear as rows. The media card covers the music one. The panel's outer opacity is 0.97.

---

## Key bar and terminal

`keybar.owl` is the bar over the keyboard while typing in a terminal: esc, tab, ctrl, alt, shift, arrows, home/end/pgup/
pgdn, copy (`ctrl+insert`), paste (`shift+insert`) and photos. Ctrl/alt/shift latch for one key, or lock until tapped
again. The prompt line types into the terminal with `typeText`/`pressKey`; photo picks paste their Linux paths. It reads
`android.modifiers`. Terminal windows and terminal tiles use the `[terminal] font` from `style.toml` — Maple Mono NF
SemiBold — which is why the font is in the backup.

---

## Fonts

`Maple Mono NF` is not a pacman package here: the 16 TTFs are in `~/.local/share/fonts/maple-mono-nf`, installed by hand.
The 37 MB of TTFs compress to about 2.5 MB with zstd, so `save.sh` packs the whole `~/.local/share/fonts` into
`fonts.tar.zst` and every backup carries it. `restore.sh` extracts it and runs `fc-cache -f`; the restore snapshot also
includes it, so **undo last restore** puts back the previous font. Add another font to `~/.local/share/fonts` and the
next save includes it too.

Check what is visible with:

```sh
fc-list | grep -i 'Maple Mono NF'
fc-match 'Maple Mono NF'
fc-cache -f ~/.local/share/fonts
```

---

## Google Calendar — `owl-agenda`

`30-agenda.owl` reads Google Calendar through `owl-agenda`, which uses the pi `google-workspace` skill and its OAuth
token. pi does not have to be running.

```sh
owl-agenda                                  # next week, in the terminal
owl-agenda 14                               # two weeks
owl-agenda json                             # what the widget reads
owl-agenda accounts                         # signed-in accounts
owl-agenda login --email you@example.com    # one-time sign-in, in the browser
```

Tokens live in `~/.pi/google-workspace/tokens/`, never in this repository. Optional defaults (account and days) can go
in `~/.config/owl-agenda/config`:

```
email=you@example.com
days=14
```

---

## Gmail — `owl-mail`

`20-mail.owl` reads Gmail through `owl-mail`, which uses the same skill and token as `owl-agenda`. A message is put
under **needs a reply** when a person wrote to you (not a list, a no-reply address or a machine notice) and the subject
or snippet asks something; the rest of the inbox follows.

```sh
owl-mail                                    # the inbox, in the terminal
owl-mail json --limit 30                    # what the widget reads
owl-mail accounts                           # signed-in accounts
owl-mail login --email you@example.com      # one-time sign-in, in the browser
```

Optional defaults (account and how many messages to fetch) can go in `~/.config/owl-mail/config`:

```
email=you@example.com
limit=30
```

---

## Dependencies

Every widget declares what its commands need in `requires { pacman: [ … ] }`. The set for this setup:

| package | used by |
| --- | --- |
| `btop` | quick settings' btop tile; the face's terminal use |
| `python` | `owl-config` (backup/restore safety), `owl-usage` (the pi spend tile) |
| `nodejs` | `owl-agenda`, `owl-mail`, `drive.js`, the Google Workspace skill |
| `git` | `save.sh` commits, `owl-config`, the maintenance tile's config row |
| `util-linux` | `setsid`, `flock` |
| `zstd` | the compressed font bundle |
| `tar` | the font bundle |
| `fontconfig` | `fc-cache` after a font restore |
| `coreutils`, `findutils`, `util-linux`, `gawk`, `sed`, `jq`, `pacman-contrib` | the storage widget's scan and clean |
| `pacman` | the face's package count, the maintenance tile's pending updates |
| `openssh`, `iproute2` | `sshd.owl` and `omarchy-sshd` (port 2222, keys only) |

Install anything missing with:

```sh
sudo pacman -S --needed btop python nodejs git util-linux zstd tar fontconfig \
  coreutils findutils gawk sed jq pacman-contrib
```

`owl-check` comes with the launcher; `fc-cache` comes with `fontconfig`. The Google skill installs its own npm
dependencies on first use (`restore.sh` does it after a restore).

---

## Backup and restore

### Saving to git

```sh
~/omalauncher-config/save.sh                 # dated message
~/omalauncher-config/save.sh "new keybar"    # your own message
```

`save.sh` copies the live setup into the repository, rebuilds `fonts.tar.zst`, commits, and pushes if a remote exists. If
nothing changed it says so and stops.

### Saving to Google Drive

```sh
~/omalauncher-config/drive-backup.sh
~/omalauncher-config/drive-backup.sh "before the layout change"
```

It saves to git, packs `HEAD` into `omalauncher-config-YYYYmmdd-HHMMSS.tar.gz`, and uploads to Drive →
**omalauncher-backups**, keeping the newest 10. `OWL_AGENDA_ACCOUNT` picks another signed-in Google account.

### From the launcher

- **backup** tile on page 4: **back up** now; tap for the list.
- **restore** tile on page 4: **restore** the newest; tap for check, list and undo.
- **backup & restore** app in the drawer: the full screen.

### The CLI

```sh
owl-config save "message"                 # save + upload
owl-config list                           # refresh the cached Drive list
owl-config check latest                   # download, validate, change nothing
owl-config restore latest                 # apply, with checks and a snapshot
owl-config restore <id|name> --dry-run    # same as check
owl-config undo                           # put back the pre-restore snapshot
owl-config status                         # what the last run said
```

### Why a restore cannot silently break things

1. **Check first.** `check newest` / `owl-config check latest` downloads the archive and validates it without touching
   the live setup: the tar is unpacked safely, `layout.toml` and `style.toml` are parsed, every widget the layout names
   is present, every `.owl` file starts with a real OWL kind, and `fonts.tar.zst` is integrity-tested with `zstd -t`.
2. **Snapshot first.** Before applying, the whole current setup is copied to
   `~/.local/share/omalauncher-restored/before-restore-<date>/`: widgets, style, home, themes, backgrounds, fonts, pi
   settings/extensions/themes, the CLI, and `AGENTS.md`.
3. **Check after applying.** `owl-check` runs on every live widget/app. A check is also made just before, so a widget that
   was already broken does not count against the restore. If a file that compiled before now says **“doesn't compile”**,
   the snapshot is put back **automatically**.
4. **Undo.** If the restore succeeds but you do not like it, **undo last restore** (or `owl-config undo`) puts the
   snapshot back. The snapshot also preserves fonts.
5. **One at a time.** `flock` stops a backup and a restore from overlapping. Everything is logged in
   `~/.cache/owl-config/log.txt`; the tiles and app read progress from `~/.cache/owl-config/status.json`.
6. **The tool survives old backups.** If an old backup contains an older `owl-config`, the current one is kept, so the
   check and undo commands stay available.

What this cannot guarantee: a widget's external service (offline weather, expired Google token), widget `persist` values
or `secret` values (kept in Android app data), and Android app data. Those show as runtime problems, not a broken home.

### Restoring on this phone, or a new one

- From the launcher: **restore** tile or **backup & restore** app → **check newest** → **restore**.
- From the terminal: `owl-config restore latest`.
- By hand: download the newest `.tar.gz` from Drive, extract it in `~`, run
  `~/omalauncher-config/restore.sh`; or clone the repository and run `restore.sh`.

`restore.sh` also sets its own copy aside under `~/.local/share/omalauncher-restored/<date>/` and `owl-check`s every
restored widget. It installs the fonts and runs `fc-cache`. After a new-phone restore, sign in to Google again:

```sh
owl-agenda login --email you@example.com
```

Re-enter any widget secrets (they are never in files) and check `fc-list` if text looks wrong.

---

## Putting this on GitHub

The repository already has local commits. Only a remote is missing (`git remote -v` is empty), so nothing has been
pushed. A **private** repository is recommended: the config contains personal paths, calendar widget settings and pi
setup, though no tokens or passwords.

### Plain git

1. On GitHub: **New repository** → name it `omalauncher-config` → **Private** → no README, no `.gitignore` → Create.
2. On the phone:

```sh
cd ~/omalauncher-config
git remote add origin https://github.com/YOUR-NAME/omalauncher-config.git
git push -u origin main
```

When asked for a password, use a **fine-grained personal access token**, not your account password: GitHub → Settings
→ Developer settings → Personal access tokens → Fine-grained tokens → Generate new token → only this repository →
Repository permissions → **Contents: Read and write** → generate and paste it. To remember it:

```sh
git config credential.helper store
```

The token then lives in `~/.git-credentials` inside this container; revoke it on GitHub if the phone goes away. After
that, `save.sh` pushes every save automatically.

### With the GitHub CLI

```sh
sudo pacman -S --needed github-cli
gh auth login
cd ~/omalauncher-config
gh repo create omalauncher-config --private --source=. --remote=origin --push
```

After either setup, `~/omalauncher-config/save.sh "message"` commits and pushes; `drive-backup.sh` does both backups.

---

## Editing and checking

After editing a widget, style or layout, save the file and run:

```sh
owl-check ~/.config/omalauncher/widgets/my-widget.owl
```

It waits for the launcher to load the saved file, prints compile errors, and gives a preview PNG (the tile and its screen,
or an app's view) at the real size. Look at it for text that overflows. Terminal tiles are not previewed.

Where errors appear:

- `~/.config/omalauncher/style/errors.txt` — style settings that were ignored.
- `~/.config/omalauncher/home/errors.txt` — layout entries that could not be read.
- `~/.config/omalauncher/widgets/.errors/<file>.txt` — compile/runtime errors for a widget; the tile shows them too.
- `~/.config/omalauncher/widgets/.preview/` — the PNGs from `owl-check`.
- `~/.cache/owl-config/log.txt` and `status.json` — backup/restore.

Scripts can set a widget's state or refresh it:

```sh
owl-send ~/.config/omalauncher/widgets/build.owl set status passing
owl-send ~/.config/omalauncher/widgets/build.owl refresh
```

After changes you want to keep:

```sh
~/omalauncher-config/save.sh "what changed"
```

or tap **back up** on page 4.

---

## Troubleshooting

| Problem | Look at |
| --- | --- |
| a widget shows `…` or part of it is missing | `widgets/.errors/<file>.txt`, then `owl-check` it |
| a style change was ignored | `style/errors.txt`; compare with `defaults.toml` |
| a tile is missing or in the wrong cell | `home/errors.txt`; edit `layout.toml` or move it on the phone |
| the drawer is broken | swipe up falls back to `drawer.owl`; `.stock-drawer.owl` is the shipped one |
| no notifications in controls | ongoing/foreground notifications are hidden by Android; media appears as the media card |
| no brightness slider in controls | Android lets a launcher read brightness but not set it; tap opens Display settings |
| text is in a fallback font | `fc-list \| grep -i 'Maple Mono NF'`; restore fonts with `restore.sh` or `fc-cache -f` |
| the agenda says "offline" | `owl-agenda accounts`, `owl-agenda login --email …`, or `owl-agenda` in a terminal |
| a backup says error | `owl-config status`, `~/.cache/owl-config/log.txt` |
| a restore went wrong | **undo last restore**, or `owl-config undo`; snapshots are in `~/.local/share/omalauncher-restored/` |

---

## Limits

- Widgets have at most 500 nodes (a face/page 1000), 2000 drawing calls per frame, and a step budget per update.
- A widget's sources run only while its page is visible (or a neighbour is), except for a widget whose screen is open.
- Ongoing notifications, the launcher's own service, and system background services are never in `android.notifications`.
- Brightness, Wi-Fi, Bluetooth, airplane mode and location are readable but not switchable by a launcher; taps open
  Android's own panels.
- Widget `persist` and `secret` values live in Android app data and are not in file backups.
- Google OAuth tokens are not in this repository; sign in again on a new phone.
- Android app data, photos, downloaded files and installed APKs are not backed up.

---

## Credits

The face is Simon Schubert's **omarchy** face; quick settings is rat0sh1's; storage is rcrohmana's; now playing is
reymarch995's; today is from the widget store. The agenda widget, `owl-agenda`, the `backup`/`restore` app and tiles,
the controls panel edits (battery, brightness, notifications header), the font bundle and `owl-config` are this phone's
own. The drawer and key bar are the launcher's stock ones. The OWL docs are in
`~/.config/omalauncher/widgets/docs/`; the launcher is at <https://github.com/SimonSchubert/omalauncher>.
