#!/bin/sh
# Puts what is saved in this repository back where omalauncher and pi read it, for a new phone or after a mess-up.
# What was there before is copied aside first, under ~/.local/share/omalauncher-restored/.
set -eu
cd "$(dirname "$0")"

if [ ! -d omalauncher ]; then
  echo "Nothing is saved here yet: run save.sh first."
  exit 1
fi

cfg=$HOME/.config/omalauncher
pi=$HOME/.pi/agent
aside=$HOME/.local/share/omalauncher-restored/$(date '+%Y%m%d-%H%M%S')
mkdir -p "$aside" "$cfg"/widgets "$cfg"/style "$cfg"/home "$pi"/extensions "$pi"/themes

# In case this undoes something you wanted: what is here now, set aside.
for d in widgets style home; do
  if [ -d "$cfg/$d" ]; then cp -a "$cfg/$d" "$aside"/; fi
done
for f in settings.json keybindings.json open-tui.json; do
  if [ -f "$pi/$f" ]; then cp -p "$pi/$f" "$aside"/; fi
done
if [ -d "$pi"/extensions ]; then cp -a "$pi"/extensions "$aside"/pi-extensions; fi
echo "What was here is set aside in $aside"

if ls omalauncher/widgets/*.owl >/dev/null 2>&1; then cp -p omalauncher/widgets/*.owl "$cfg"/widgets/; fi
if ls omalauncher/style/*.toml >/dev/null 2>&1; then cp -p omalauncher/style/*.toml "$cfg"/style/; fi
if [ -f omalauncher/home/layout.toml ]; then cp -p omalauncher/home/layout.toml "$cfg"/home/; fi
if [ -f omalauncher/agent ]; then cp -p omalauncher/agent "$cfg"/; fi

mkdir -p "$HOME"/.config/omarchy
if [ -d omarchy/themes ]; then cp -Rp omarchy/themes "$HOME"/.config/omarchy/; fi
if [ -d omarchy/backgrounds ]; then cp -Rp omarchy/backgrounds "$HOME"/.config/omarchy/; fi

if [ -d pi/agent/extensions ]; then cp -Rp pi/agent/extensions/. "$pi"/extensions/; fi
for f in settings.json keybindings.json open-tui.json; do
  if [ -f "pi/agent/$f" ]; then cp -p "pi/agent/$f" "$pi"/; fi
done
if [ -d pi/agent/themes ]; then cp -Rp pi/agent/themes/. "$pi"/themes/; fi
if [ -f AGENTS.md ]; then cp -p AGENTS.md "$HOME"/; fi

echo "Restored. The launcher picks the widgets up within seconds; pi' extensions load as it starts."
for f in "$cfg"/widgets/*.owl; do owl-check "$f" >/dev/null 2>&1 || owl-check "$f"; done
