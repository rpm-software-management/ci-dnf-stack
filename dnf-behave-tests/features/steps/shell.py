# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import sys

import behave
import pexpect

from common import *


@behave.step("I open dnf shell session")
def when_I_open_dnf_shell(context):
    cmd = " ".join(context.dnf.get_cmd(context)) + " shell"
    context.cmd = cmd
    context.dnf["rpmdb_pre"] = get_rpmdb_rpms(context.dnf.installroot)

    context.shell_session = pexpect.spawn(cmd)
    # pexpect adds a short delay before sending data, so that SSH has time
    # to turn off TTY echo; the echo is still there though, so removing the delay
    context.shell_session.delaybeforesend = None
    
    context.shell_session.expect('> ')
    stdout_from_shell(context)


@behave.step("I execute in dnf shell \"{command}\"")
def when_I_execute_in_shell(context, command):
    if context.shell_session is None:
        raise AssertionError("dnf shell session must be opened first")

    context.dnf["rpmdb_pre"] = get_rpmdb_rpms(context.dnf.installroot)

    context.shell_session.sendline(command)

    if command.strip() == "quit" or command.strip() == "exit":
        context.shell_session.expect(pexpect.EOF)
        stdout_from_shell(context)
        context.shell_session = None
        return

    # previously, there was timeout=600 added in commit 415d980eb34e8fd0487f1be3da14a8c279b74993
    # but it's probably not needed anymore
    context.shell_session.expect("\r\n[^ \r-]*> ")
    stdout_from_shell(context)
