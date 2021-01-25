# -*- coding: utf-8 -*-

import behave

from common.lib.cmd import run_in_context
from common.lib.file import prepend_installroot

@behave.step("I execute createrepo_c with args \"{arguments}\" in \"{directory}\"")
def when_I_execute_createrepo_c_in_directory(context, arguments, directory):
    target_path = prepend_installroot(context, directory)
    run_in_context(context, "createrepo_c " + arguments.format(context=context), cwd=target_path, can_fail=True)


@behave.step("I execute modifyrepo_c with args \"{arguments}\" in \"{directory}\"")
def when_I_execute_modifyrepo_c_in_directory(context, arguments, directory):
    target_path = prepend_installroot(context, directory)
    run_in_context(context, "modifyrepo_c " + arguments.format(context=context), cwd=target_path, can_fail=True)


@behave.step("I execute mergerepo_c with args \"{arguments}\" in \"{directory}\"")
def when_I_execute_mergerepo_c_in_directory(context, arguments, directory):
    target_path = prepend_installroot(context, directory)
    run_in_context(context, "mergerepo_c " + arguments.format(context=context), cwd=target_path, can_fail=True)


@behave.step("I execute sqliterepo_c with args \"{arguments}\" in \"{directory}\"")
def when_I_execute_sqliterepo_c_in_directory(context, arguments, directory):
    target_path = prepend_installroot(context, directory)
    run_in_context(context, "sqliterepo_c " + arguments.format(context=context), cwd=target_path, can_fail=True)
