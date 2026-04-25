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
"""

try:
    # this host_vars.py should be populated by home-manager, sourced from
    # nixos-config/thalin/hosts/<hostname>/host_vars.py
    from .host_vars import options as host_options

    logger.info("Imported host_vars.options")
except ImportError:
    logger.info("Unable to import host_vars.options")

# Options with defaults
options = {
    "term": "kitty",
    "bar_height": 4 * 16,
    "fake_screens": {},
    "widget_font_size": 24,
    "systray_icon_size": 36,
    "upower_widget_enable": False,
    "battery": False,
}

if host_options is not None:
    options.update(host_options)
