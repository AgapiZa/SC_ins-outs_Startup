#!/bin/zsh

set -e

SCRIPT_DIR="${0:A:h}"
SOURCE="$SCRIPT_DIR/sc-audio-startup-gui.scd"
TARGET_DIR="$HOME/Library/Application Support/SuperCollider"
TARGET="$TARGET_DIR/startup.scd"
BACKUP="$TARGET_DIR/startup.scd.backup.$(date +%Y%m%d-%H%M%S)"

if [ ! -f "$SOURCE" ]; then
	echo "Could not find:"
	echo "$SOURCE"
	echo ""
	echo "Keep install.command in the same folder as sc-audio-startup-gui.scd."
	read -k 1 "?Press any key to close..."
	exit 1
fi

mkdir -p "$TARGET_DIR"

if [ -f "$TARGET" ]; then
	cp "$TARGET" "$BACKUP"
	echo "Existing startup.scd backed up to:"
	echo "$BACKUP"
	echo ""
fi

cp "$SOURCE" "$TARGET"

echo "Installed SuperCollider startup file:"
echo "$TARGET"
echo ""
echo "Close and reopen SuperCollider."
echo "The audio devices GUI should open automatically."
echo ""
read -k 1 "?Press any key to close..."
