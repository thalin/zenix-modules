from qtile_extras import widget
from qtile_extras.widget.decorations import PowerLineDecoration

from .vars import options
from .themes.gruvbox import theme

widget_font_size = options.get("widget_font_size", 24)
systray_icon_size = options.get("systray_icon_size", 36)

# Widget defaults
widget_defaults = dict(
#  font='sans',
  font='Monospace Regular',
  fontsize=widget_font_size,
  padding=3,
)

extension_defaults = widget_defaults.copy()

# Powerline decorations
powerline_left = {
  "decorations": [
    PowerLineDecoration(path='arrow_left'),
  ]
}

powerline_right = {
  "decorations": [
    PowerLineDecoration(path='arrow_right'),
  ]
}

# Widget factory, top
def widget_factory_top(i, total_screens):
  widgets = [
    widget.CurrentLayoutIcon(padding=10, background=theme["faded_purple"], foreground=theme["light0"], **powerline_left),
    widget.WindowName(width=700, scroll=True, background=theme["faded_blue"], foreground=theme["light0"], **powerline_left),
    widget.Spacer(background=theme["dark0_95"], **powerline_right),
  ];
  # Add some widgets to last screen
  if i == total_screens - 1:
    widgets.extend([
      widget.Systray(icon_size=systray_icon_size, background=theme["dark1"]),
      widget.Spacer(length=10, background=theme["dark1"], **powerline_right),
      widget.PulseVolume(step=5, fmt="🔊 {}", limit_max_volume=True, background=theme["faded_blue"], foreground=theme["dark0"]),
    ])
    if options.get("upower_widget_enable", False):
      widgets.extend([
        widget.UPowerWidget(background=theme["neutral_purple"]),
        widget.Spacer(length=10, background=theme["neutral_purple"]),
      ])
  return widgets

# Widget factory, bottom
def widget_factory_bottom(i, total_screens):
  widgets = [
    widget.GroupBox(padding=10,
                    spacing=5,
                    center_aligned=True,
                    disable_drag=True,
                    highlight_method='block',
                    block_highlight_text_color=theme['light0'],
                    background=theme['dark2'],
                    this_current_screen_border=theme['bright_blue'],
                    this_screen_border=theme['neutral_blue'],
                    urgent_block=theme['neutral_yellow'],
                    **powerline_left),
    widget.Prompt(background=theme['dark1'],
                 foreground=theme['light1'],
                  prompt='$ ',
                  **powerline_left),
    widget.Spacer(**powerline_right),
  ]
  if i == total_screens - 1:
    widgets.extend([
      widget.Clock(background=theme['faded_blue'],
                   foreground=theme['light0'],
                   format='%Y-%m-%d %a %I:%M %p'),
    ])
  return widgets
