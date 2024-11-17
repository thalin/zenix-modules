from libqtile.lazy import lazy
from libqtile.config import Key
from libqtile.config import Key, Drag, Click
#from libqtile.log_utils import logger

from .groups import group_map
from .logging import logger
from .vars import options

mod = "mod4" # windows key
alt = "mod1"
shift = "shift"
ctrl = "control"

logger.info('Constructing keys')
keys = [

  # Slightly modified from default recommendations for MonadTall
  Key([mod], "h", lazy.layout.left()),
  Key([mod], "l", lazy.layout.right()),
  Key([mod], "j", lazy.layout.down()),
  Key([mod], "k", lazy.layout.up()),
  Key([mod], "Left", lazy.layout.swap_left()),
  Key([mod], "Right", lazy.layout.swap_right()),
  Key([mod], "Down", lazy.layout.shuffle_down()),
  Key([mod], "Up", lazy.layout.shuffle_up()),
  Key([mod, shift], "Up", lazy.layout.grow()),
  Key([mod, shift], "Down", lazy.layout.shrink()),
  Key([mod], "n", lazy.layout.normalize()),
  Key([mod], "m", lazy.layout.maximize()),
  Key([mod, shift], "space", lazy.layout.flip()),

  # Switch window focus to other pane(s) of stack
  Key([alt], "Tab", lazy.layout.next()),
  Key([alt, shift], "Tab", lazy.layout.previous()),

  # Swap panes of split stack
  #Key([mod, shift], "space", lazy.layout.rotate()),

  # Toggle between split and unsplit sides of stack.
  # Split = all windows displayed
  # Unsplit = 1 window displayed, like Max layout, but still with
  # multiple stack panes
  Key([mod, shift], "Return", lazy.layout.toggle_split()),
  Key([mod], "Return", lazy.spawn(options['term'])),
  Key([mod, shift], "l", lazy.spawn(cmd="xsecurelock", env={"XSECURELOCK_NO_COMPOSITE": "1"})),
  Key([alt, ctrl], "s", lazy.spawn("gnome-screenshot -a")),

  # Toggle between different layouts as defined below
  Key([mod], "Tab", lazy.next_layout()),
  Key([mod], "c", lazy.window.kill()),

  # Media keys
  Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -10%")),
  Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +10%")),
  Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),

  # Qtile stuff - restart, shutdown, run command
  Key([mod, ctrl], "r", lazy.restart()),
  Key([mod, ctrl], "q", lazy.shutdown()),
  Key([mod], "p", lazy.spawncmd()),
]

logger.info('Constructing desktop keymaps')
for k, g in group_map.items():
  #logger.info('Setting key {} to group {}'.format(k, g.name))
  keys.extend([
    # alt + fkey of group = switch to group
    Key([alt], k, lazy.group[g.name].toscreen()),

    # mod + fkey of group = move focused window to group
    Key([mod], k, lazy.window.togroup(g.name)),
  ])

# Drag floating layouts.
mouse = [
  Drag([mod], "Button1", lazy.window.set_position_floating(),
       start=lazy.window.get_position()),
  Drag([mod], "Button3", lazy.window.set_size_floating(),
       start=lazy.window.get_size()),
  Click([mod], "Button3", lazy.window.disable_floating()),
  Click([mod], "Button2", lazy.window.bring_to_front())
]
