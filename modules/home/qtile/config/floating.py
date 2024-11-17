from libqtile import layout
from libqtile.config import Match

# Run the utility of `xprop` to see the wm class and name of an X client.
# default_float_rules include: utility, notification, toolbar, splash, dialog,
# file_progress, confirm, download and error.
floating_layout = layout.Floating(
  float_rules=[
    *layout.Floating.default_float_rules,
    Match(wm_class="confirmreset"),  # gitk
    Match(wm_class="makebranch"),  # gitk
    Match(wm_class="maketag"),  # gitk
    Match(title="branchdialog"),  # gitk
    Match(wm_class="ssh-askpass"),  # ssh-askpass
  ]
)
