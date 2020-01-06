# -*- coding: utf-8 -*-

import behave
import os
import glob

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


@behave.step("I set umask to \"{octal_mode_str}\"")
def set_umask(context, octal_mode_str):
    os.umask(int(octal_mode_str, 8))


@behave.step("file \"{filepath}\" has mode \"{octal_mode_str}\"")
def file_has_mode(context, filepath, octal_mode_str):
    octal_mode = int(octal_mode_str, 8)
    matched_files = glob.glob(prepend_installroot(context, filepath))
    if len(matched_files) < 1:
        raise AssertionError("No files matching: {0}".format(filepath))
    if len(matched_files) > 1:
        raise AssertionError("Multiple files matching: {0} found:\n{1}" .format(filepath, '\n'.join(matched_files)))
    octal_file_mode = os.stat(matched_files[0]).st_mode & 0o777
    assert oct(octal_mode) == oct(octal_file_mode), \
        "File \"{}\" has mode \"{}\"".format(matched_files[0], oct(octal_file_mode))
