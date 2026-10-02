import os

from libqtile.scratchpad import ScratchPad
from qtile_extras import widget
from qtile_extras.widget.decorations import PowerLineDecoration
from qtile_extras.widget.groupbox2 import GroupBoxRule

from .vars import options
from .themes.gruvbox import theme

widget_font_size = options.get("widget_font_size", 24)
systray_icon_size = options.get("systray_icon_size", 36)

# Widget defaults
widget_defaults = dict(
    #  font='sans',
    font="Monospace Regular",
    fontsize=widget_font_size,
    padding=3,
)

extension_defaults = widget_defaults.copy()

# Powerline decorations
powerline_left = {
    "decorations": [
        PowerLineDecoration(path="arrow_left"),
    ]
}

powerline_right = {
    "decorations": [
        PowerLineDecoration(path="arrow_right"),
    ]
}


# Left inset for the label; the right side gets whatever's left over after
# the label plus the arrow's own reach plus a small gap - see box_size below.
GROUP_PADDING_LEFT = 8
GROUP_ARROW_GAP = 6  # breathing room between the label and the arrow's tail


def _group_fill_colour(group, qtile):
    """Returns (block_colour, text_colour) for a group's current status.

    Grey scale only, darker = less active; urgent is the one exception that
    keeps a warning colour so real errors stay noticeable."""
    if any(w.urgent for w in group.windows):
        return theme["neutral_yellow"], theme["dark0_hard"]
    if qtile.current_group is group:
        return theme["light4"], theme["dark0_hard"]
    if group.windows:
        return theme["dark3"], theme["light1"]
    return theme["dark1"], theme["light4"]


def _arrow_edge_width(bar_height):
    return bar_height * 0.35


def _text_width(box, text):
    layout = box.drawer.textlayout(
        text, "ffffff", box.font, box.fontsize, box.fontshadow, markup=box.markup
    )
    return layout.width


def _set_group_format(rule, box):
    rule.block_colour, rule.text_colour = _group_fill_colour(box.group, box.qtile)

    text = box.group.label or box.group.name
    edge = _arrow_edge_width(box.bar.height)
    rule.box_size = int(
        GROUP_PADDING_LEFT + _text_width(box, text) + GROUP_ARROW_GAP + edge
    )
    return True


def _visible_groups(qtile):
    # Mirrors GroupBox2._get_groups()'s own filtering so box.index lines up.
    return [g for g in qtile.groups if not isinstance(g, ScratchPad)]


def _draw_powerline_edge(box):
    """Draw a small right-pointing arrowhead at the box's right edge, in the
    box's own colour, blending into the next group's actual colour - matches
    the PowerLineDecoration look used elsewhere in this bar, scoped to a
    small strip at the edge rather than the whole box."""
    ctx = box.drawer.ctx
    w, h = box.size, box.bar.height
    edge = min(_arrow_edge_width(h), w / 2)

    groups = _visible_groups(box.qtile)
    idx = box.index + 1
    if idx < len(groups):
        next_colour, _ = _group_fill_colour(groups[idx], box.qtile)
    else:
        next_colour = box.bar.background  # widget's own background

    ctx.new_path()
    ctx.rectangle(w - edge, 0, edge, h)
    box.drawer.set_source_rgb(next_colour)
    ctx.fill()

    ctx.new_path()
    ctx.move_to(w - edge, 0)
    ctx.line_to(w, h / 2)
    ctx.line_to(w - edge, h)
    ctx.close_path()
    box.drawer.set_source_rgb(box.block_colour)
    ctx.fill()


group_box_rules = [
    GroupBoxRule(custom_draw=_draw_powerline_edge).when(func=_set_group_format),
]


# voxtype dictation daemon writes its current state here; reading the file
# is much cheaper than spawning `voxtype status` on every poll.
VOXTYPE_STATE_FILE = os.path.join(
    os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"), "voxtype", "state"
)
VOXTYPE_STATES = {
    "idle": ("🎙", theme["light4"]),
    "recording": ("🎙 REC", theme["bright_red"]),
    "transcribing": ("🎙 ...", theme["bright_yellow"]),
}


def _voxtype_status():
    """Bar text for the voxtype state; empty (zero-width) when it isn't running."""
    try:
        with open(VOXTYPE_STATE_FILE) as f:
            state = f.read().strip()
    except OSError:
        return ""
    text, colour = VOXTYPE_STATES.get(state, (f"🎙 {state}", theme["light4"]))
    return f'<span foreground="{colour}">{text}</span>'


# Widget factory, top
def widget_factory_top(main=False):
    widgets = [
        widget.CurrentLayoutIcon(
            padding=10,
            background=theme["faded_purple"],
            foreground=theme["light0"],
            **powerline_left
        ),
        widget.WindowName(
            width=700,
            scroll=True,
            background=theme["faded_blue"],
            foreground=theme["light0"],
            **powerline_left
        ),
        widget.Spacer(background=theme["dark0_95"], **powerline_right),
    ]
    # Add some widgets to main screen
    if main:
        widgets.extend(
            [
                # Systray (legacy XEmbed) still covers X11-only tray apps;
                # qtile itself auto-drops this widget under the wayland
                # backend (XEmbed doesn't exist there), so no conditional
                # needed here.
                widget.Systray(icon_size=systray_icon_size, background=theme["dark1"]),
                # StatusNotifier uses the freedesktop StatusNotifierItem/
                # AppIndicator DBus spec instead, which works on both X11
                # and Wayland, covering the apps Systray can't under wayland.
                widget.StatusNotifier(
                    icon_size=systray_icon_size, background=theme["dark1"]
                ),
                widget.Spacer(length=10, background=theme["dark1"], **powerline_right),
                widget.PulseVolume(
                    step=5,
                    fmt="🔊 {}",
                    limit_max_volume=True,
                    background=theme["faded_blue"],
                    foreground=theme["dark0"],
                ),
            ]
        )
        if options.get("upower_widget_enable", False):
            widgets.extend(
                [
                    widget.Spacer(length=10, background=theme["faded_blue"], **powerline_right),
                    widget.UPowerWidget(background=theme["neutral_purple"]),
                    widget.Spacer(length=10, background=theme["neutral_purple"]),
                ]
            )
        if options.get("battery", False):
            widgets.extend(
                [
                    widget.Spacer(length=10, background=theme["faded_blue"], **powerline_right),
                    widget.BatteryIcon(background=theme["neutral_purple"]),
                    widget.Battery(background=theme["neutral_purple"]),
                    widget.Spacer(length=10, background=theme["neutral_purple"]),
                ]
            )
    return widgets


# Widget factory, bottom
def widget_factory_bottom(main=False):
    """Populate some widgets.

    ``main`` adds the voxtype indicator to the main screen's bar only."""
    voxtype = [
        # Shares the clock's background so the spacer's arrow runs into both;
        # zero-width on hosts without voxtype (no state file)
        widget.GenPollText(
            func=_voxtype_status,
            update_interval=0.25,
            padding=10,
            background=theme["faded_blue"],
        ),
    ] if main else []
    widgets = [
        widget.GroupBox2(
            padding_x=GROUP_PADDING_LEFT,
            padding_y=6,
            margin=0,
            rules=group_box_rules,
            background=theme["dark0"],
        ),
        widget.Prompt(
            background=theme["dark1"],
            foreground=theme["light1"],
            prompt="$ ",
            **powerline_left
        ),
        widget.Spacer(**powerline_right),
        *voxtype,
        widget.Clock(
            background=theme["faded_blue"],
            foreground=theme["light0"],
            format="%Y-%m-%d %a %I:%M %p",
        ),
    ]
    return widgets
