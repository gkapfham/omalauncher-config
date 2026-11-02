#!/bin/sh
# Saves this setup to the local git repository, tars it, and uploads the tar to
# Google Drive -> omalauncher-backups, keeping the newest 10 there.
#
#   ~/omalauncher-config/drive-backup.sh                 # dated message
#   ~/omalauncher-config/drive-backup.sh "new keybar"
#
# The Google account is the one already signed in for the agenda (owl-agenda);
# set OWL_AGENDA_ACCOUNT to pick another.
set -eu
cd "$(dirname "$0")"

./save.sh "${1:-backup $(date '+%Y-%m-%d %H:%M')}"

stamp=$(date '+%Y%m%d-%H%M%S')
out="${TMPDIR:-/tmp}/omalauncher-config-$stamp.tar.gz"
trap 'rm -f "$out"' EXIT

# The whole repository at HEAD, as a clean tree (no .git; the local repository keeps the history).
git archive --format=tar.gz --prefix=omalauncher-config/ -o "$out" HEAD

email=${OWL_AGENDA_ACCOUNT:-$(node "$HOME/.pi/agent/skills/google-workspace/scripts/auth.js" accounts 2>/dev/null | sed -n 's/^- email: //p' | head -1)}
if [ -z "$email" ]; then
  echo "No Google account is signed in: run owl-agenda login --email you@example.com" >&2
  exit 1
fi

node "$(dirname "$0")/drive.js" upload "$out" "$email" 10
