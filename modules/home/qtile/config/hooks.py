import os
import subprocess

from libqtile import hook

# from libqtile.log_utils import logger
from .logging import logger
from .vars import options

logger.info("Registering Qtile hooks")


@hook.subscribe.startup_complete
def import_wayland_systemd_environment():
    """Import WAYLAND_DISPLAY into systemd --user so units gated on it can start.

    Compositors like sway/hyprland run `systemctl --user import-environment`
    themselves during their own startup; qtile doesn't. Without it, systemd's
    user manager never sees WAYLAND_DISPLAY at all (it's set inside qtile's
    own process, not exported anywhere systemd can see), so any unit using
    ConditionEnvironment=WAYLAND_DISPLAY (e.g. home-manager's wpaperd
    service) fails its condition check and silently never starts -
    graphical-session.target is already reached (and dependents already
    attempted) before this hook ever runs, so a plain import isn't enough;
    the previously-skipped unit needs an explicit restart too.
    """
    if os.environ.get("WAYLAND_DISPLAY") is None:
        return

    subprocess.Popen(
        [
            "sh",
            "-c",
            "systemctl --user import-environment WAYLAND_DISPLAY "
            "&& systemctl --user restart wpaperd.service",
        ]
    )


@hook.subscribe.startup_complete
def configure_x11_outputs():
    """Apply x11_outputs via xrandr once the X11 backend is up.

    The X server doesn't always come up at the highest refresh rate a mode
    supports on its own (kernel/EDID may pick a lower default), same
    underlying issue as wayland_outputs. xrandr talks to a separate Xorg
    process rather than qtile itself, so unlike wlr-randr there's no
    self-deadlock risk here, but Popen is used anyway for consistency.
    """
    if os.environ.get("WAYLAND_DISPLAY") is not None:
        return

    for out in options.get("x11_outputs", []):
        name = out.get("output")
        mode = out.get("mode")
        if not name or not mode:
            logger.info(f"Skipping invalid x11_outputs entry: {out}")
            continue

        args = ["xrandr", "--output", name, "--mode", mode]
        if out.get("rate"):
            args += ["--rate", str(out["rate"])]
        if out.get("primary"):
            args += ["--primary"]

        logger.info(f"Setting X11 output {name} to mode {mode}")
        with open("/home/thalin/qtile-config.log", "a") as log_file:
            subprocess.Popen(args, stdout=log_file, stderr=log_file)


@hook.subscribe.client_new
def force_tiled_windows(client):
    """Force specific wm_classes to tile instead of float.

    Some apps (e.g. Wine/Proton games with fixed-size WM hints) get
    auto-floated by qtile's default float heuristics, then request their
    own floating geometry that ignores/overlaps qtile's bars. Tiled
    placement already respects bar space correctly via the normal layout
    engine, so forcing tiled sidesteps the bad geometry entirely instead
    of trying to override it with hardcoded coordinates.
    """
    wm_class = client.window.get_wm_class() or ()
    for cls in options.get("force_tiled_wm_classes", []):
        if cls in wm_class:
            logger.info(f"Forcing tiled placement for wm_class {wm_class}")
            client.floating = False
            break


@hook.subscribe.client_new
def group_steam_windows(client):
    """Keep the Steam client and Steam-launched games on one group.

    switch_group defaults to False, so this moves the window without
    yanking focus away from whatever group is currently being viewed -
    important since Steam's client/overlay spawns many background helper
    windows that shouldn't interrupt whatever else is going on.
    """
    steam_group = options.get("steam_group")
    if not steam_group:
        return

    wm_class = client.window.get_wm_class() or ()
    is_steam = any(
        c.lower() == "steam" or c.lower().startswith("steam_app_") for c in wm_class
    )
    if is_steam:
        logger.info(f"Sending steam window {wm_class} to group {steam_group}")
        client.togroup(steam_group)


@hook.subscribe.startup_complete
def configure_wayland_outputs():
    """Apply wayland_outputs via wlr-randr once the wayland backend is up.

    wlr-randr talks to qtile's own compositor over wlr-output-management, so
    it needs qtile's event loop to be free to service that request. Calling
    it with subprocess.run() (blocking) from inside a hook deadlocks the
    whole compositor: the hook is running on the event loop thread, so
    subprocess.run() blocks that thread, so wlr-randr never gets a reply,
    so subprocess.run() never returns. Popen (fire-and-forget) avoids this.
    """
    if os.environ.get("WAYLAND_DISPLAY") is None:
        return

    for out in options.get("wayland_outputs", []):
        name = out.get("output")
        mode = out.get("mode")
        if not name or not mode:
            logger.info(f"Skipping invalid wayland_outputs entry: {out}")
            continue

        # --custom-mode (vs --mode) doesn't require an exact match against the
        # compositor's EDID-enumerated refresh rates (which are often
        # inexact, e.g. 119.997002Hz instead of a round 120Hz).
        args = ["wlr-randr", "--output", name, "--custom-mode", mode]
        if out.get("position"):
            args += ["--pos", out["position"]]
        if out.get("scale"):
            args += ["--scale", str(out["scale"])]

        logger.info(f"Setting wayland output {name} to mode {mode}")
        with open("/home/thalin/qtile-config.log", "a") as log_file:
            subprocess.Popen(args, stdout=log_file, stderr=log_file)

# def detect_screens(qtile):
#  """
#  Detect if a new screen is plugged and reconfigure/restart qtile
#  """
#  logger.info('config.py detect_screens')
#
#  def setup_monitors(action=None, device=None):
#    """
#    Add 1 group per screen
#    """
#    logger.info('config.py setup_monitors')
#
#    if action == "change":
#      # setup monitors with xrandr
#      # call("setup_screens")
#      lazy.restart()
#
#      nbr_screens = len(qtile.conn.pseudoscreens)
#      for i in xrange(0, nbr_screens-1):
#        groups.append(Group('h%sx' % (i+5), persist=False))
#  setup_monitors()
#
#  import pyudev
#
#  context = pyudev.Context()
#  monitor = pyudev.Monitor.from_netlink(context)
#  monitor.filter_by('drm')
#  monitor.enable_receiving()
#
#  # observe if the monitors change and reset monitors config
#  observer = pyudev.MonitorObserver(monitor, setup_monitors)
#  observer.start()

# @hook.subscribe.client_new
# def new_client(client):
#  if client.window.get_wm_class()[0] == "screenkey":
#    client.static(0)


@hook.subscribe.screen_change
def restart_on_randr(ev):
    pass
    # logger.info("restart_on_randr event attributes: {}".format(dir(ev)))
    # logger.info(f"""Other attributes:
    #             bufsize: {ev.bufsize}, config_timestamp: {ev.config_timestamp}
    #             width: {ev.width}, height: {ev.height}
    #             mwidth: {ev.mwidth}, mheight: {ev.mheight}
    #             pack: {ev.pack}, request_window: {ev.request_window}
    #             response_type: {ev.response_type}, root: {ev.root}
    #             rotation: {ev.rotation}, sequence: {ev.sequence}
    #             sizeID: {ev.sizeID}, subpixel_order: {ev.subpixel_order}
    #             synthetic: {ev.synthetic}, timestamp: {ev.timestamp}
    #             unpacker: {ev.unpacker}, xge: {ev.xge}""")


#  qtile.cmd_restart()

# @hook.subscribe.startup_once
# def autostart():
#   logger.info("startup_once event: starting autostart applications")
#   script = os.path.expanduser("~/.config/qtile/autostart.sh")
# subprocess.run([script])
