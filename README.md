# omalauncher setup

This phone's omalauncher look and its pi setup, kept in git so a reinstall, a new phone or a bad edit costs nothing.
`save.sh` copies the live files in here and pushes; `restore.sh` puts them back.

## What is saved

| here | lives at |
| --- | --- |
| `omalauncher/widgets/*.owl` | `~/.config/omalauncher/widgets/` — the widget files, the drawer, the terminal key bar with its prompt line |
| `omalauncher/style/` | `~/.config/omalauncher/style/` — theme, background, tile spacing, terminal font |
| `omalauncher/home/layout.toml` | `~/.config/omalauncher/home/` — pages, faces, tiles and where each one sits |
| `omarchy/themes/`, `omarchy/backgrounds/` | `~/.config/omarchy/` — your own themes and wallpapers (the `vitamin` theme among them) |
| `pi/agent/extensions/` | `~/.pi/agent/extensions/` — `swipe-prompt.ts`, which turns what the pi tile's line sends into a prompt |
| `pi/agent/settings.json`, `keybindings.json`, `open-tui.json`, `themes/` | `~/.pi/agent/` |
| `AGENTS.md` | `~/AGENTS.md` — what pi reads about this phone |
| `bin/owl-agenda` | `~/.local/bin/` — the calendar CLI behind the `agenda` widget; also usable in pi and any terminal |
| `bin/owl-config` | `~/.local/bin/` — the backup/restore CLI behind the `backup` app |
| `pi/agent/skills/google-workspace/` | `~/.pi/agent/skills/` — Gregory's Google Workspace skill (OAuth + `googleapis`), which needs `npm install` once; `restore.sh` does that |

Deliberately **not** saved: `pi/agent/auth.json` (your API keys), `pi/agent/sessions/` (the conversations), caches,
`.stock-*` files and `.removed/` widgets — the launcher hands those out again by itself.

## Saving

```sh
~/omalauncher-config/save.sh                # dated message
~/omalauncher-config/save.sh "new keybar"   # or your own
```

It copies, commits and pushes in one go. Nothing to do when nothing changed; it says so and stops.

## Backing up to Google Drive

The phone is already signed in to Google for the agenda, so the backup can leave the phone without setting up GitHub:

```sh
~/omalauncher-config/drive-backup.sh                # dated message
~/omalauncher-config/drive-backup.sh "new keybar"   # or your own
```

It saves as above, packs the repository at `HEAD` into `omalauncher-config-YYYYmmdd-HHMMSS.tar.gz`, and uploads it to
Google Drive → **omalauncher-backups**, keeping the newest 10. Set `OWL_AGENDA_ACCOUNT` to use another signed-in Google
account.

To restore, download the newest `.tar.gz` from Drive, extract it in `~` (it expands to `~/omalauncher-config/`), then run
`~/omalauncher-config/restore.sh`. The archive holds no tokens or API keys; sign in again with
`owl-agenda login --email you@example.com` if the agenda needs it.

## Backup & restore from the launcher

`backup.owl` adds **backup & restore** to the app drawer. It has **back up now** and **refresh list**, shows how the last
run went, and lists the Drive backups newest first, each with **restore**. Restore asks first, and the current setup is set
aside under `~/.local/share/omalauncher-restored/` before anything is replaced.

The same thing from a terminal:

```sh
owl-config save "before changing the home layout"
owl-config list
owl-config restore latest
owl-config restore <id|name> --dry-run   # download and check, change nothing
owl-config status
```

`owl-config` keeps a lock so two runs can't overlap, writes progress to `~/.cache/owl-config/status.json` (what the app
shows), and logs to `~/.cache/owl-config/log.txt`. A restore downloads the archive, checks it is an omalauncher backup,
and only then applies it.

**Not in any backup:** widget `persist` state and `secret` values (the launcher keeps those in its Android app data, not
in files), Google tokens, and fonts. Re-enter secrets and sign in again on a new phone.

## Restoring

```sh
~/omalauncher-config/restore.sh
```

It sets aside what is there now (`~/.local/share/omalauncher-restored/<date>/`), copies the saved files back, and
`owl-check`s every restored widget so a broken one shows up instead of just not drawing.

## First-time setup on GitHub

1. In a browser, make a repository — **Private** is enough: github.com → New repository → name it `omalauncher-config`
   → no README, no .gitignore → Create.
2. Point this copy at it (replace `YOU`):

   ```sh
   cd ~/omalauncher-config
   git remote add origin https://github.com/YOU/omalauncher-config.git
   git config credential.helper store      # remember the token, so later saves don't ask
   git push -u origin main
   ```

   The push asks for a username and a password. The username is your GitHub name; for the password, use a **token**,
   not your account password: GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens →
   Generate new token → only this repository → Repository permissions → **Contents: Read and write** → generate, then
   paste it when git asks. It is stored in `~/.git-credentials` inside this container, which only this phone can read;
   revoke it on that GitHub page if the phone ever goes away.

From then on, `save.sh` pushes without asking.

## Doing it from another machine

The same repository restores anywhere omalauncher runs — clone it, run `restore.sh` — and you can edit widget files on
a laptop, commit, and pull them onto the phone with `cd ~/omalauncher-config && git pull && ./restore.sh`.

## The agenda widget

`30-agenda.owl` shows the next days of your Google calendars. It is standalone: `owl-agenda` asks Google itself with
the token the `google-workspace` skill keeps, so pi never has to be running.

```sh
owl-agenda                      # the next week, in the terminal (and in pi's bash)
owl-agenda 14                   # two weeks
owl-agenda json                 # what the widget reads
owl-agenda accounts             # who is signed in
owl-agenda login --email you@example.com   # the one-time Google sign-in, in the browser
```

Signing in is once per account; the token lives in `~/.pi/google-workspace/tokens/` (never in this repository).
Defaults — the account and how many days — go in `~/.config/owl-agenda/config`:

```
email=you@example.com
days=14
```
