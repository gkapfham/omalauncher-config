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
if [ -d "$HOME"/.local/share/fonts ]; then cp -a "$HOME"/.local/share/fonts "$aside"/fonts; fi
echo "What was here is set aside in $aside"

if ls omalauncher/widgets/*.owl >/dev/null 2>&1; then cp -p omalauncher/widgets/*.owl "$cfg"/widgets/; fi
if ls omalauncher/style/*.toml >/dev/null 2>&1; then cp -p omalauncher/style/*.toml "$cfg"/style/; fi
if [ -f omalauncher/home/layout.toml ]; then cp -p omalauncher/home/layout.toml "$cfg"/home/; fi
if [ -f omalauncher/agent ]; then cp -p omalauncher/agent "$cfg"/; fi

mkdir -p "$HOME"/.config/omarchy
if [ -d omarchy/themes ]; then cp -Rp omarchy/themes "$HOME"/.config/omarchy/; fi
if [ -d omarchy/backgrounds ]; then cp -Rp omarchy/backgrounds "$HOME"/.config/omarchy/; fi

# The fonts the style and terminal use. fc-cache makes them visible to the launcher.
if [ -f fonts.tar.zst ]; then
  zstd -t fonts.tar.zst >/dev/null 2>&1 || { echo "fonts.tar.zst is corrupt" >&2; exit 1; }
  zstd -q -dc fonts.tar.zst | tar -C "$HOME"/.local/share -xf -
  fc-cache -f "$HOME"/.local/share/fonts >/dev/null 2>&1 || true
fi

if [ -d pi/agent/extensions ]; then cp -Rp pi/agent/extensions/. "$pi"/extensions/; fi
for f in settings.json keybindings.json open-tui.json; do
  if [ -f "pi/agent/$f" ]; then cp -p "pi/agent/$f" "$pi"/; fi
done
if [ -d pi/agent/themes ]; then cp -Rp pi/agent/themes/. "$pi"/themes/; fi
if [ -f AGENTS.md ]; then cp -p AGENTS.md "$HOME"/; fi

if [ -f bin/owl-agenda ]; then
  mkdir -p "$HOME"/.local/bin
  cp -p bin/owl-agenda "$HOME"/.local/bin/
  chmod +x "$HOME"/.local/bin/owl-agenda
fi
if [ -f bin/owl-config ]; then
  mkdir -p "$HOME"/.local/bin
  cp -p bin/owl-config "$HOME"/.local/bin/
  chmod +x "$HOME"/.local/bin/owl-config
fi
if [ -d pi/agent/skills ]; then
  cp -Rp pi/agent/skills/. "$pi"/skills/
  # The skill's npm deps are not in the repository; npm puts them back.
  for skill in "$pi"/skills/*/; do
    if [ -f "$skill/package.json" ] && [ ! -d "$skill/node_modules" ]; then
      echo "Installing ${skill}package.json dependencies (a minute or two)…"
      (cd "$skill" && npm install --omit=dev --no-audit --no-fund) || echo "run by hand: cd $skill && npm install"
    fi
  done
fi

echo "Restored. The launcher picks the widgets up within seconds; pi's extensions load as it starts."
for f in "$cfg"/widgets/*.owl; do owl-check "$f" >/dev/null 2>&1 || owl-check "$f"; done
