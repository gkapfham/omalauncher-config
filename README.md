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

Deliberately **not** saved: `pi/agent/auth.json` (your API keys), `pi/agent/sessions/` (the conversations), caches,
`.stock-*` files and `.removed/` widgets — the launcher hands those out again by itself.

## Saving

```sh
~/omalauncher-config/save.sh                # dated message
~/omalauncher-config/save.sh "new keybar"   # or your own
```

It copies, commits and pushes in one go. Nothing to do when nothing changed; it says so and stops.

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
