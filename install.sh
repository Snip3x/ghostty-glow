#!/usr/bin/env sh
# Installs glow.glsl (and the optional Glow Forest theme) into your Ghostty config dir.
set -e
here=$(cd "$(dirname "$0")" && pwd)
dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
mkdir -p "$dir/shaders" "$dir/themes"
cp "$here/shaders/glow.glsl" "$dir/shaders/glow.glsl"
cp "$here/themes/glow-forest" "$dir/themes/glow-forest"
echo "Installed to $dir"
echo
echo "Add this to your Ghostty config, then reload (ctrl+shift+, or restart):"
echo "  custom-shader = $dir/shaders/glow.glsl"
echo
echo "Optional matching theme:"
echo "  theme = glow-forest"
