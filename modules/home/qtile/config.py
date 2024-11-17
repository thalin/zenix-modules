# Import config

from .config import *

#from .config import (
#        keys,
#        mouse,
#        groups,
#        term,
#        layouts,
#        widget_defaults,
#        extension_defaults,
#        floating_layout,
#        screens,
#        hooks,
#        logger,
#        )

logger.info('Setting options')
dgroup_key_binder = None
dgroup_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = True
auto_fullscreen = True
focus_on_window_activation = "smart"

# Java compatibility bullshit
wmname = "LG3D"

#main = None
