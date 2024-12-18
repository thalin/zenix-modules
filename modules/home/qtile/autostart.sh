#!/usr/bin/env zsh

# Network manager applet
# Removed this on nixws - may need to reenable for other machines
#nm-applet &

# Desktop backgrounds
nitrogen --restore --random

# Screenshot tool
flameshot &

# Compositor
#picom -b

# Clean up qtile pycaches
find ~/.config/qtile -type d -name __pycache__ -exec rm -r {} \+
