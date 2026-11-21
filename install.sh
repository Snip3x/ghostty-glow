#!/usr/bin/env sh
# ghostty-glow installer
#
#   ./install.sh               install shader and enable it in your Ghostty config
#   ./install.sh --theme       also install and enable the Glow Forest theme
#   ./install.sh --uninstall   remove everything this script added
#
# One-liner (no clone needed):
#   curl -fsSL https://raw.githubusercontent.com/Snip3x/ghostty-glow/main/install.sh | sh
#   curl -fsSL https://raw.githubusercontent.com/Snip3x/ghostty-glow/main/install.sh | sh -s -- --theme
set -eu

REPO_RAW="https://raw.githubusercontent.com/Snip3x/ghostty-glow/main"
MARK="# added by ghostty-glow"

DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
SHADER="$DIR/shaders/glow.glsl"
THEME="$DIR/themes/glow-forest"

WITH_THEME=0
UNINSTALL=0
for arg in "$@"; do
    case "$arg" in
        --theme) WITH_THEME=1 ;;
        --uninstall) UNINSTALL=1 ;;
        -h|--help) sed -n '2,10p' "$0" 2>/dev/null || true; exit 0 ;;
        *) echo "unknown option: $arg" >&2; exit 1 ;;
    esac
done

say() { printf '  \033[1;32m>\033[0m %s\n' "$1"; }
warn() { printf '  \033[1;33m!\033[0m %s\n' "$1"; }

# Ghostty reads "config.ghostty" (newer) or "config". Use whichever exists.
if [ -f "$DIR/config.ghostty" ]; then
    CONFIG="$DIR/config.ghostty"
else
    CONFIG="$DIR/config"
fi

if [ "$UNINSTALL" -eq 1 ]; then
    if [ -f "$CONFIG" ]; then
        tmp="$CONFIG.tmp.$$"
        # drop each marker line and the setting line right after it
        awk -v m="$MARK" '$0==m {skip=1; next} skip {skip=0; next} {print}' "$CONFIG" > "$tmp"
        mv "$tmp" "$CONFIG"
        say "removed ghostty-glow lines from $CONFIG"
    fi
    rm -f "$SHADER" "$THEME"
    say "removed shader and theme files"
    echo
    echo "  Reload Ghostty (ctrl+shift+,) or open a new window."
    exit 0
fi

# Fetch a repo file: copy it if we're running from a clone, otherwise download it.
HERE=""
case "$0" in
    */*) [ -f "$0" ] && HERE=$(cd "$(dirname "$0")" && pwd) ;;
esac
fetch() { # fetch <repo-path> <dest>
    mkdir -p "$(dirname "$2")"
    if [ -n "$HERE" ] && [ -f "$HERE/$1" ]; then
        cp "$HERE/$1" "$2"
    elif command -v curl >/dev/null 2>&1; then
        curl -fsSL "$REPO_RAW/$1" -o "$2"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$2" "$REPO_RAW/$1"
    else
        echo "need curl or wget to download $1" >&2; exit 1
    fi
}

echo
echo "  ghostty-glow"
echo

fetch shaders/glow.glsl "$SHADER"
say "shader  -> $SHADER"

if [ "$WITH_THEME" -eq 1 ]; then
    fetch themes/glow-forest "$THEME"
    say "theme   -> $THEME"
fi

mkdir -p "$DIR"
touch "$CONFIG"
cp "$CONFIG" "$CONFIG.bak-ghostty-glow"
say "backup  -> $CONFIG.bak-ghostty-glow"

if grep -q "glow.glsl" "$CONFIG"; then
    say "shader already enabled in $CONFIG"
else
    if grep -q '^[[:space:]]*custom-shader[[:space:]]*=' "$CONFIG"; then
        warn "you already use another custom-shader; Ghostty will stack them"
    fi
    printf '\n%s\ncustom-shader = %s\n' "$MARK" "$SHADER" >> "$CONFIG"
    say "enabled shader in $CONFIG"
fi

if [ "$WITH_THEME" -eq 1 ]; then
    if grep -q '^[[:space:]]*theme[[:space:]]*=[[:space:]]*glow-forest' "$CONFIG"; then
        say "theme already enabled"
    else
        if grep -q '^[[:space:]]*\(theme\|background\|foreground\|palette\)[[:space:]]*=' "$CONFIG"; then
            warn "your config sets its own colours; those will override glow-forest"
        fi
        printf '%s\ntheme = glow-forest\n' "$MARK" >> "$CONFIG"
        say "enabled theme glow-forest"
    fi
fi

echo
echo "  Done. Reload Ghostty (ctrl+shift+,) or open a new window."
echo "  Tweak strength/spread at the top of $SHADER"
echo "  Undo with: ./install.sh --uninstall"
echo
