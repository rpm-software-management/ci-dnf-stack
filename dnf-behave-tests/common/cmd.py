# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave

from common.lib.cmd import run_in_context


@behave.step("I set working directory to \"{working_dir}\"")
def i_set_working_directory(context, working_dir):
    context.dnf.working_dir = working_dir.format(context=context)


@behave.step("I execute \"{command}\" in \"{directory}\"")
def when_I_execute_command_in_directory(context, command, directory):
    run_in_context(context, command.format(context=context), cwd=directory.format(context=context))


@behave.step("I execute \"{command}\"")
def when_I_execute_command(context, command):
    run_in_context(context, command.format(context=context))
