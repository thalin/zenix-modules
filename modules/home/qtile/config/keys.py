import os
import signal

from libqtile.lazy import lazy
from libqtile.config import Key
from libqtile.config import Key, Drag, Click

# from libqtile.log_utils import logger

from .groups import group_map
from .logging import logger
from .vars import options


def _descendant_pids(pid):
    """Return [pid] plus every descendant pid, via /proc's kernel-provided child list.

    Deliberately not process-group based: the wayland session is exec'd
    straight from the sddm session script with no setsid, so qtile itself
    and every app it spawns can end up sharing one process group. A
    group-based kill can take out qtile (and the whole session) along with
    the target app. Walking /proc's actual parent/child tree can only ever
    reach real descendants of `pid`.
    """
    pids = [pid]
    try:
        with open(f"/proc/{pid}/task/{pid}/children") as f:
            children = [int(p) for p in f.read().split()]
    except (FileNotFoundError, ProcessLookupError):
        children = []
    for child in children:
        pids.extend(_descendant_pids(child))
    return pids


@lazy.function
def kill_process_tree(qtile):
    """Forcibly kill the focused window's whole process tree.

    lazy.window.kill() only closes the one window/toplevel; for apps like
    browsers that keep many windows in a single process, that leaves the
    rest of the app running instead of triggering its crash/session-restore
    behavior on next launch. This is the wayland-native equivalent of what
    xkill effectively achieved on X11: an unclean, unrecoverable kill of the
    whole app, not just the window under the cursor.
    """
    win = qtile.current_window
    if win is None:
        return
    try:
        pid = win.get_pid()
    except AttributeError as e:
        logger.info(f"kill_process_tree: failed to get pid: {e}")
        return

    pids = _descendant_pids(pid)
    logger.info(f"kill_process_tree: killing pids {pids}")
    for p in pids:
        try:
            os.kill(p, signal.SIGKILL)
        except ProcessLookupError:
            pass

mod = "mod4"  # windows key
alt = "mod1"
shift = "shift"
ctrl = "control"

logger.info("Constructing keys")
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
    # Key([mod, shift], "space", lazy.layout.rotate()),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, shift], "Return", lazy.layout.toggle_split()),
    Key([mod], "Return", lazy.spawn(options["term"])),
    Key([mod], "BackSpace", lazy.spawn(options["term"])),
    Key([mod], "f", lazy.window.toggle_fullscreen()),
    Key(
        [mod, shift],
        "l",
        lazy.spawn(cmd="xsecurelock", env={"XSECURELOCK_NO_COMPOSITE": "1"}),
    ),
    Key([alt, ctrl], "s", lazy.spawn("gnome-screenshot -a")),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout()),
    Key([mod], "c", lazy.window.kill()),
    Key([mod, shift], "c", kill_process_tree),
    # Media keys
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -10%"),
    ),
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +10%"),
    ),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),
    # Qtile stuff - restart, shutdown, launcher (shift+arrows switch rofi modes)
    Key([mod, ctrl], "r", lazy.restart()),
    Key([mod, ctrl], "q", lazy.shutdown()),
    Key([mod], "p", lazy.spawn("rofi -show drun")),
]

logger.info("Constructing desktop keymaps")
for k, g in group_map.items():
    # logger.info('Setting key {} to group {}'.format(k, g.name))
    keys.extend(
        [
            # alt + fkey of group = switch to group
            Key([alt], k, lazy.group[g.name].toscreen()),
            # mod + fkey of group = move focused window to group
            Key([mod], k, lazy.window.togroup(g.name)),
        ]
    )

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button3", lazy.window.disable_floating()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]
