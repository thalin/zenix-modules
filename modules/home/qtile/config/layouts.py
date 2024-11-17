#from libqtile.log_utils import logger

from libqtile import layout

from .themes.gruvbox import theme

from .logging import logger

window_margin = 8
window_border = 2

logger.info('Constructing layouts')

layouts = [
  layout.MonadTall(
      margin=window_margin,
      border_width=window_border,
      single_margin=window_margin,
      border_focus=theme['faded_aqua'],
      border_normal=theme['dark0'],
      ),
  layout.RatioTile(
      margin=window_margin,
      border_width=window_border,
      border_focus=theme['faded_aqua'],
      border_normal=theme['dark0'],
      ),
  layout.Max(
      margin=window_margin,
      border_width=window_border,
      border_focus=theme['faded_aqua'],
      border_normal=theme['dark0'],
      ),
  layout.TreeTab(
      margin=window_margin,
      border_width=window_border,
      # border_focus=theme['faded_aqua'],
      # border_normal=theme['dark0'],
      ),
  #layout.Stack(num_stacks=2),
]
