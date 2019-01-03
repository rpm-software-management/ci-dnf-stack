import sys

import behave

from common import *


@behave.step("I execute dnf with args \"{args}\"")
def when_I_execute_dnf_with_args(context, args):
    cmd = " ".join(context.dnf.get_cmd(context))
    cmd += " " + args
    context.dnf["rpmdb_pre"] = get_rpmdb_rpms(context.dnf.installroot)
    context.cmd = cmd
    context.cmd_exitcode, context.cmd_stdout, context.cmd_stderr = run(cmd, shell=True)


@behave.step("I execute \"{command}\" with args \"{args}\"")
def when_I_execute_command_with_args(context, command, args):
    cmd = command + " " + args
    context.cmd = cmd
    context.cmd_exitcode, context.cmd_stdout, context.cmd_stderr = run(cmd, shell=True)


@behave.then("the exit code is {exitcode}")
def then_the_exit_code_is(context, exitcode):
    if context.cmd_exitcode == int(exitcode):
        return
    print(context.cmd_stdout)
    print(context.cmd_stderr, file=sys.stderr)
    raise AssertionError("Command has returned exit code {0}: {1}".format(context.cmd_exitcode, context.cmd))
