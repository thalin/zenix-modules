from collections import OrderedDict

#from libqtile.log_utils import logger
from libqtile.config import Group

from .logging import logger
from .vars import options

logger.info('Constructing group_map')
group_map = OrderedDict([
  ("F1", Group(
    "F1",
    spawn="librewolf",
    layout="max",
  )),
  ("F2", Group(
    "F2",
    # spawn="brave",
    layout="max",
  )),
  ("F3", Group(
    "F3",
    # spawn="steam",
    layout="max",
  )),
  ("F4", Group(
    "F4",
    spawn="slack",
    layout="max",
  )),
])
  
# Generate terminal groups
for i in range(5,9):
  fkey = f'F{i}'
  # fkey = "F{}".format(i)
  group_map[fkey] = Group(fkey, spawn=options['term'], layout="ratiotile")

# Generate unreserved groups
for i in range(9,13):
  fkey = f'F{i}'
  # fkey = "F{}".format(i)
  group_map[fkey] = Group(fkey, layout="ratiotile")

groups = list(group_map.values())
