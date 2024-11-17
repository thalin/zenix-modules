from .logging import logger

from .vars import options

#import .hooks
from .hooks import *

from .widgets import widget_defaults, extension_defaults

if 'fake_screens' in options:
    from .screens import fake_screens
else:
    from .screens import screens

from .layouts import layouts
from .groups import groups

from .keys import keys, mouse
from .floating import floating_layout

term = options['term']
