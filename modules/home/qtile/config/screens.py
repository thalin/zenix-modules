from functools import partial
#from qtile.log_utils import logger

from libqtile.config import Screen
from libqtile import bar

# Moved into widgets.py
# from qtile_extras import widget
# from qtile_extras.widget.decorations import PowerLineDecoration

from .widgets import widget_factory_top, widget_factory_bottom
from .logging import logger
from .vars import options
from .themes.gruvbox import theme


# powerline_left = {
#   "decorations": [
#     PowerLineDecoration(path='arrow_left'),
#   ]
# }
#
# powerline_right = {
#   "decorations": [
#     PowerLineDecoration(path='arrow_right'),
#   ]
# }

logger.info('Constructing screens')
# defaultScreens = [
#   Screen(
#     top=bar.Bar(
#       [
#         widget.CurrentLayoutIcon(padding=10, background=theme["faded_purple"], foreground=theme["light0"], **powerline_left),
#         widget.WindowName(width=700, scroll=True, background=theme["faded_blue"], foreground=theme["light0"], **powerline_left),
#         widget.Spacer(background=theme["dark0_95"], **powerline_right),
#         widget.Systray(icon_size=36, background=theme["dark1"]),
#         widget.Spacer(length=10, background=theme["dark1"], **powerline_right),
#         widget.PulseVolume(step=5, fmt="🔊 {}", limit_max_volume=True, background=theme["faded_blue"], foreground=theme["dark0"]),
#         #widget.UPowerWidget(background=theme["neutral_purple"]),
#         #widget.Spacer(length=10, background=theme["neutral_purple"]),
#       ],
#       options['bar_height'],
#       background=theme["dark0"],
#     ),
#     bottom=bar.Bar(
#       [
#         widget.GroupBox(padding=10,
#                         spacing=5,
#                         center_aligned=True,
#                         disable_drag=True,
#                         highlight_method='block',
#                         block_highlight_text_color=theme['light0'],
#                         background=theme['dark2'],
#                         this_current_screen_border=theme['bright_blue'],
#                         this_screen_border=theme['neutral_blue'],
#                         urgent_block=theme['neutral_yellow'],
#                         **powerline_left),
#         widget.Prompt(background=theme['dark1'],
#                       foreground=theme['light1'],
#                       prompt='$ ',
#                       **powerline_left),
#         widget.Spacer(**powerline_right),
#         widget.Clock(background=theme['faded_blue'],
#                      foreground=theme['light0'],
#                      format='%Y-%m-%d %a %I:%M %p'),
#       ],
#       options['bar_height'],
#       background=theme["dark0_95"],
#     ),
#   ),
# ]


# def widget_factory_top(i, total_screens):
#   widgets = [
#     widget.CurrentLayoutIcon(padding=10, background=theme["faded_purple"], foreground=theme["light0"], **powerline_left),
#     widget.WindowName(width=700, scroll=True, background=theme["faded_blue"], foreground=theme["light0"], **powerline_left),
#     widget.Spacer(background=theme["dark0_95"], **powerline_right),
#   ];
#   # Add some widgets to last screen
#   if i == total_screens - 1:
#     widgets.extend([
#       widget.Systray(icon_size=36, background=theme["dark1"]),
#       widget.Spacer(length=10, background=theme["dark1"], **powerline_right),
#       widget.PulseVolume(step=5, fmt="🔊 {}", limit_max_volume=True, background=theme["faded_blue"], foreground=theme["dark0"]),
#       #widget.UPowerWidget(background=theme["neutral_purple"]),
#       #widget.Spacer(length=10, background=theme["neutral_purple"]),
#     ])
#   return widgets
#
#
# def widget_factory_bottom(i, total_screens):
#   widgets = [
#     widget.GroupBox(padding=10,
#                     spacing=5,
#                     center_aligned=True,
#                     disable_drag=True,
#                     highlight_method='block',
#                     block_highlight_text_color=theme['light0'],
#                     background=theme['dark2'],
#                     this_current_screen_border=theme['bright_blue'],
#                     this_screen_border=theme['neutral_blue'],
#                     urgent_block=theme['neutral_yellow'],
#                     **powerline_left),
#     widget.Prompt(background=theme['dark1'],
#                  foreground=theme['light1'],
#                   prompt='$ ',
#                   **powerline_left),
#     widget.Spacer(**powerline_right),
#   ]
#   if i == total_screens - 1:
#     widgets.extend([
#       widget.Clock(background=theme['faded_blue'],
#                    foreground=theme['light0'],
#                    format='%Y-%m-%d %a %I:%M %p'),
#     ])
#   return widgets


def bar_factory(size, widget_factory):
  return bar.Bar(widget_factory(), size=size, background=theme["dark0"])


def make_screens(widths, height, bar_size):
  now_x = 0
  screens = []
  if len(widths) == 0 or len(widths) == 1:
    screens.append(
      Screen(
        top=bar_factory(bar_size, partial(widget_factory_top, i=0, total_screens=1)),
        bottom=bar_factory(bar_size, partial(widget_factory_bottom, i=0, total_screens=1))
      )
    )
  for i, width in enumerate(widths):
    screens.append(
      Screen(
        top=bar_factory(bar_size, partial(widget_factory_top, i=i, total_screens=len(widths))),
        bottom=bar_factory(bar_size, partial(widget_factory_bottom, i=i, total_screens=len(widths))),
        x=now_x,
        y=0,
        width=width,
        height=height,
      )
    )
    now_x += width
  return screens
# 1920 - 1920 - 1280
rect = [1920, 1920, 1280]
sidebars = [1280, 2560, 1280]
height = 1440
bar_size = 25

if 'fake_screens' in options:
  logger.info("Making fake screens!")
  fs_opts = options['fake_screens']
  fake_screens = make_screens(fs_opts["widths"], fs_opts["height"], options["bar_height"])
  # Swap the screens so that screen 0 is the middle screen and thus gets the
  # first group assigned to it instead of the left fake screen
  fake_screens[0], fake_screens[1] = fake_screens[1], fake_screens[0]
else:
  logger.info("Making regular screens")
  screens = make_screens([], None, options["bar_height"])
