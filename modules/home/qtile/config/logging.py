import logging

logging.basicConfig(filename='/home/thalin/qtile-config.log',
                    filemode='a',
                    format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                    datefmt='%H:%M:%S',
                    level=logging.DEBUG)

# Set up logging to a file in the home directory

logger = logging.getLogger(__name__)

for handler in logger.handlers:
    logger.removeHandler(handler)

fh = logging.FileHandler('/home/thalin/qtile-config.log')
fh.setLevel(logging.DEBUG)

formatter = logging.Formatter('%(asctime)s,%(msecs)d %(name)s %(levelname)s: %(message)s')
fh.setFormatter(formatter)

logger.addHandler(fh)
