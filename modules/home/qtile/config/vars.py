import os
import json
from .logging import logger

host_options = None

"""
OPTIONS SO FAR:
term:
    type: string
    description: terminal pprogram to launch
    default: kitty
bar_height:
    type: integer 
    default: 4*16
    description: sets the bar height for top and bottom qtile bars
fake_screens:
    type: dictionary
    default: {}
    description: fake screen options, see below
    sub options:
        widths:
            type: list of integers
            default: undefined
            description: fake screen widths
        height:
            type: integer
            default: undefined
            description: fake screen heights
widget_font_size:
    type: integer
    default: 24
    description: font size for widget text on qtile bars
systray_icon_size:
    type: integer
    default: 36
    description: size of systray icons
upower_widget_enable:
    type: bool
    default: false
    description: should the main top bar include the qtile-extended upower widget
battery:
    type: bool
    default: false
    description: should the main top bar include qtile battery widget
wayland_outputs:
    type: list of dicts
    default: []
    description: outputs to configure via wlr-randr when running under the wayland backend
    sub options (per dict):
        output:
            type: string
            description: output/connector name, e.g. "DP-3"
        mode:
            type: string
            description: mode to set, e.g. "7680x2160@120Hz" (needs the Hz suffix)
        position:
            type: string
            default: undefined
            description: optional position, e.g. "0,0"
        scale:
            type: float
            default: undefined
            description: optional per-output scale factor, e.g. 1.25
x11_outputs:
    type: list of dicts
    default: []
    description: outputs to configure via xrandr when running under the x11 backend
    sub options (per dict):
        output:
            type: string
            description: output/connector name, e.g. "DP-3"
        mode:
            type: string
            description: mode to set, e.g. "7680x2160"
        rate:
            type: string
            default: undefined
            description: optional refresh rate, e.g. "120.00"
        primary:
            type: bool
            default: false
            description: whether to mark this output primary
force_tiled_wm_classes:
    type: list of strings
    default: []
    description: |
        wm_class values to force tiled (never floating), e.g. for apps
        with fixed-size WM hints that make qtile auto-float them, whose
        own requested floating geometry ends up ignoring/overlapping the
        bars. Tiled placement already respects bar space correctly.
steam_group:
    type: string
    default: undefined
    description: |
        If set, keep the Steam client (wm_class "Steam") and any window
        Steam itself actually launches (wm_class "steam_app_<appid>") on
        this group. Games merely run via steam-run (the NixOS FHS compat
        shim, not Steam's own launcher) don't match this and are
        unaffected.
notifications:
    type: bool
    default: false
    description: |
        Put a qtile Notify widget at the right end of the main top bar. It *is* the
        notification daemon (org.freedesktop.Notifications), so don't enable
        it alongside dunst/mako. Notifications stay until clicked away;
        scroll for older ones, right click runs the default action.
timers:
    type: dictionary
    default: undefined
    description: countdown timers on the main top bar (left of notifications), see timers.py
    sub options:
        presets:
            type: list of dicts
            default: []
            description: fixed timers, one widget each
            sub options (per dict):
                name:
                    type: string
                    description: timer name, also the widget name "timer_<name>"
                duration:
                    type: string or number
                    description: e.g. "4m", "1h30m", "90s"; bare numbers are seconds
                icon:
                    type: string
                    default: "⏲"
                step:
                    type: string or number
                    default: "1m"
                    description: how much one scroll tick adjusts the timer
        adhoc:
            type: bool
            default: true
            description: add the ad-hoc timers widget ("adhoc_timers")
"""

host_vars_json_path = os.path.join(os.path.dirname(__file__), 'host_vars.json')

try:
    if os.path.exists(host_vars_json_path):
        with open(host_vars_json_path, 'r') as f:
            host_options = json.load(f)
        logger.info("Imported host_vars.json")
    else:
        logger.info("host_vars.json not found")
except Exception as e:
    logger.info(f"Unable to load host_vars.json: {e}")

# Options with defaults
options = {
    "term": "kitty",
    "bar_height": 4 * 16,
    "fake_screens": {},
    "widget_font_size": 24,
    "systray_icon_size": 36,
    "upower_widget_enable": False,
    "battery": False,
    "wayland_outputs": [],
    "x11_outputs": [],
    "force_tiled_wm_classes": [],
}

if host_options is not None:
    options.update(host_options)
