import os
import subprocess

from libqtile import hook

#from libqtile.log_utils import logger
from .logging import logger

logger.info('Registering Qtile hooks')

#def detect_screens(qtile):
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

#@hook.subscribe.client_new
#def new_client(client):
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
  #subprocess.run([script])
