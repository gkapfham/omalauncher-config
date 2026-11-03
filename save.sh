#!/bin/sh
# Copies the parts of this phone's setup that are yours into the repository, commits them and pushes.
# Run it after changing a widget, the style, the home layout, a theme or a pi extension:
#
#   ~/omalauncher-config/save.sh            # message is the date and time
#   ~/omalauncher-config/save.sh "new keybar"
#
# What is left out, on purpose: pi's auth.json (your API keys), pi's sessions (the conversations themselves),
# and caches, .stock-* files and .removed/ widgets, which the launcher can hand out again.
set -eu
cd "$(dirname "$0")"

cfg=$HOME/.config/omalauncher
pi=$HOME/.pi/agent

# From scratch each time, so a widget, theme or background you deleted goes from the backup too.
rm -rf omalauncher omarchy pi AGENTS.md

# omalauncher: the widget files, the style and what's where on home.
mkdir -p omalauncher/widgets omalauncher/style omalauncher/home
for f in "$cfg"/widgets/*.owl; do
  case $(basename "$f") in .stock-*) continue ;; esac
  cp -p "$f" omalauncher/widgets/
done
cp -p "$cfg"/style/style.toml "$cfg"/style/defaults.toml omalauncher/style/
cp -p "$cfg"/home/layout.toml omalauncher/home/
if [ -f "$cfg"/agent ]; then cp -p "$cfg"/agent omalauncher/; fi

# The look: your themes and backgrounds.
mkdir -p omarchy
if [ -d "$HOME"/.config/omarchy/themes ]; then cp -Rp "$HOME"/.config/omarchy/themes omarchy/themes; fi
if [ -d "$HOME"/.config/omarchy/backgrounds ]; then cp -Rp "$HOME"/.config/omarchy/backgrounds omarchy/backgrounds; fi

# Hand-installed fonts (Maple Mono NF among them): TTF compresses well with zstd,
# so the whole family fits in every backup. restore.sh puts it back and runs fc-cache.
if [ -d "$HOME"/.local/share/fonts ]; then
  tar -C "$HOME"/.local/share -cf - fonts | zstd -q -f -T0 -19 -o fonts.tar.zst
else
  rm -f fonts.tar.zst
fi

# pi: extensions (the swipe prompt inbox among them), settings, keybindings, themes.
mkdir -p pi/agent/extensions pi/agent/themes
if [ -d "$pi"/extensions ]; then cp -Rp "$pi"/extensions/. pi/agent/extensions/; fi
for f in settings.json keybindings.json open-tui.json; do
  if [ -f "$pi/$f" ]; then cp -p "$pi/$f" pi/agent/; fi
done
if [ -d "$pi"/themes ]; then cp -Rp "$pi"/themes/. pi/agent/themes/; fi
if [ -f "$HOME"/AGENTS.md ]; then cp -p "$HOME"/AGENTS.md .; fi

# owl-agenda, the calendar CLI, and the pi skill it asks Google through. Not the skill's node_modules (220 MB);
# restore.sh installs those again with npm.
mkdir -p bin pi/agent/skills
if [ -f "$HOME"/.local/bin/owl-agenda ]; then cp -p "$HOME"/.local/bin/owl-agenda bin/; fi
if [ -f "$HOME"/.local/bin/owl-config ]; then cp -p "$HOME"/.local/bin/owl-config bin/; fi
if [ -d "$pi"/skills ]; then tar -C "$pi"/skills --exclude=node_modules -cf - . | tar -C pi/agent/skills -xf -; fi

git add -A
if git diff --cached --quiet; then
  echo "Nothing has changed since the last save."
  exit 0
fi
git commit -q -m "${1:-save $(date '+%Y-%m-%d %H:%M')}"
echo "Saved $(git ls-files | wc -l | tr -d ' ') files."
if git remote | grep -q .; then
  git push -q && echo "Pushed to GitHub."
else
  echo "No GitHub repository set up yet: see README.md, then run save.sh again."
fi
