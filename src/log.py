# -*- coding: utf-8 -*-

import logging


def log_debug(msg):
    logging.basicConfig(
        format='%(asctime)s %(message)s',
        datefmt='%Y/%m/%d %p %I:%M:%S',
        filename="/root/share/var/log/error.log",
        level=logging.DEBUG
    )
    logging.debug(msg)
