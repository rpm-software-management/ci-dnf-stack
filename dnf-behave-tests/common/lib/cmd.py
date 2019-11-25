# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

from behave.formatter.ansi_escapes import escapes
import subprocess


def run(cmd, shell=True, cwd=None):
    """
    Run a command.
    Return exitcode, stdout, stderr
    """

    proc = subprocess.Popen(
        cmd,
        shell=shell,
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
    )

    stdout, stderr = proc.communicate()
    return proc.returncode, stdout, stderr


def run_in_context(context, cmd, can_fail=False, **run_args):
    if getattr(context, "faketime", None) is not None:
        cmd = context.faketime + cmd

    context.cmd = cmd

    if hasattr(context.scenario, "working_dir") and 'cwd' not in run_args:
        run_args['cwd'] = context.scenario.working_dir

    context.cmd_exitcode, context.cmd_stdout, context.cmd_stderr = run(cmd, **run_args)

    if not can_fail and context.cmd_exitcode != 0:
        raise AssertionError('Running command "%s" failed: %s' % (cmd, context.cmd_exitcode))


def assert_exitcode(context, exitcode):
    assert context.cmd_exitcode == int(exitcode), \
        "Command has returned exit code {0}: {1}".format(context.cmd_exitcode, context.cmd)


def print_last_command(context):
    if getattr(context, "cmd", ""):
        print(
            "%sLast Command: %s%s" %
            (escapes["failed"], escapes["failed_arg"], context.cmd)
        )
        print(escapes["reset"])
    if getattr(context, "cmd_stdout", ""):
        print("%sLast Command stdout:%s" % (escapes['outline_arg'], escapes['executing']))
        print(context.cmd_stdout.strip())
        print(escapes["reset"])
    if getattr(context, "cmd_stderr", ""):
        print("%sLast Command stderr:%s" % (escapes['outline_arg'], escapes['executing']))
        print(context.cmd_stderr.strip())
        print(escapes["reset"])
