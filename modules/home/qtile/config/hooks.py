import os
import subprocess

from libqtile import hook

# from libqtile.log_utils import logger
from .logging import logger
from .vars import options

logger.info("Registering Qtile hooks")


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
