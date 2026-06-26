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
}

if host_options is not None:
    options.update(host_options)
