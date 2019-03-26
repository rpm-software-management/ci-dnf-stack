# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function


def stdout_from_shell(context):
    # Few notes:
    #   1. replacing CR/LF with just LF
    #   2. at the begining, there might also be TTY echo (the command that was sent)
    context.cmd_stdout = context.shell_session.before.decode().replace("\r\n", "\n")
