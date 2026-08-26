#!/usr/bin/env zsh

# Make session env vars visible to systemd --user (mirrors the import
# qtile's wayland startup_complete hook does), so ConditionEnvironment
# gated units (e.g. wallpaper-rotate.service) can actually start. DISPLAY
# alone isn't enough for X11 clients spawned by systemd - they also need
# XAUTHORITY (a fresh, session-specific cookie path each login) or they
# fail with "Authorization required, but no authorization protocol
# specified". graphical-session.target is reached (and dependents already
# attempted) before this script runs, so previously-skipped/failed units
# need an explicit restart too, not just the import.
systemctl --user import-environment DISPLAY XAUTHORITY
systemctl --user restart wallpaper-rotate.service
# picom.service (zen.gui.picom) hits the same "no authorization protocol
# specified" failure without this - it happens to self-heal via its own
# Restart=always retries, but only after ~8 failed attempts (~25s), and
# anything that spawns a window before it recovers (e.g. qtile's own
# terminal-group auto-spawns) never gets a compositing-capable visual for
# the rest of the session.
systemctl --user restart picom.service

# Network manager applet
# Removed this on nixws - may need to reenable for other machines
#nm-applet &

# Desktop backgrounds
# (Wallpaper rotation is handled by a systemd --user timer instead - see
# services.wpaperd for wayland and the wallpaper-rotate service for X11 in
# the host's home config - since nitrogen has no periodic-rotation mode.)

# Screenshot tool
flameshot &

# Clean up qtile pycaches
find ~/.config/qtile -type d -name __pycache__ -exec rm -r {} \+
