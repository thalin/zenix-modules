from functools import partial

from libqtile.config import Screen
from libqtile import bar

from .widgets import widget_factory_top, widget_factory_bottom
from .logging import logger
from .vars import options
from .themes.gruvbox import theme


logger.info('Constructing screens')

def bar_factory(size, widget_factory, main_screen):
  return bar.Bar(widget_factory(main_screen), size=size, background=theme["dark0"])


def make_screens(widths, height, main_screen, bar_size):
  now_x = 0
  screens = []
  if len(widths) == 0 or len(widths) == 1:
    screens.append(
      Screen(
        top=bar_factory(bar_size, widget_factory_top, True),
        bottom=bar_factory(bar_size, widget_factory_bottom, True)
      )
    )
  for i, width in enumerate(widths):
    screens.append(
      Screen(
        top=bar_factory(bar_size, widget_factory_top, i == main_screen),
        bottom=bar_factory(bar_size, widget_factory_bottom, i == main_screen),
        x=now_x,
        y=0,
        width=width,
        height=height,
      )
    )
    now_x += width
  return screens

if 'fake_screens' in options:
  logger.info("Making fake screens")
  fs_opts = options['fake_screens']
  fake_screens = make_screens(fs_opts["widths"],
                              fs_opts["height"],
                              fs_opts["main_screen"],
                              options["bar_height"])
  # Swap the screens so that screen 0 is the middle screen and thus gets the
  # first group assigned to it instead of the left fake screen
  fake_screens[0], fake_screens[1] = fake_screens[1], fake_screens[0]
else:
  logger.info("Making regular screens")
  screens = make_screens([], None, 0, options["bar_height"])
