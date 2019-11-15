# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import os
import re
import sys
from datetime import datetime

import behave

from common import *
from common.string import print_lines_diff


def handle_reposync(expected, found):
    if expected[0] == "<REPOSYNC>":
        sync_line = re.compile(r".*[0-9.]+ +[kMG]?B/s \| +[0-9.]+ +[kMG]?B +[0-9]{2}:[0-9]{2}")
        last_check_line = re.compile(r"Last metadata expiration check: .*")
        i = 0

        while i < len(found) and (
                sync_line.fullmatch(found[i].strip())
                or last_check_line.fullmatch(found[i].strip())):
            i += 1

        expected = expected[1:]
        found = found[i:]

    return expected, found


@behave.step("I execute step \"{step}\"")
def execute_step(context, step):
    context.execute_steps(step)

@behave.step("I set working directory to \"{working_dir}\"")
def i_set_working_directory(context, working_dir):
    context.dnf.working_dir = working_dir.format(context=context)

@behave.step("I move the clock {direction} to \"{when}\"")
def faketime(context, direction, when):
    assert os.path.exists('/usr/bin/faketime'), 'Faketime binary must be installed'
    if when == 'before boot-up':
        stamp = get_boot_time() - 24 * 60 * 60  # 1 day before boot-up
        time = datetime.utcfromtimestamp(stamp)
        assert direction == 'backward', 'Boot time is always in the past'
    elif when == 'the present':
        context.faketime = None
        return
    else:
        time = when
    context.faketime = "faketime '%s' " % time


@behave.step("today is {when}")
def faketime_today(context, when):
    context.execute_steps('when I move the clock backward to "{}"'.format(when))


@behave.step("I execute dnf with args \"{args}\"")
def when_I_execute_dnf_with_args(context, args):
    cmd = " ".join(context.dnf.get_cmd(context))
    cmd += " " + args.format(context=context)
    context.dnf["rpmdb_pre"] = get_rpmdb_rpms(context.dnf.installroot)
    run_in_context(context, cmd, can_fail=True)


@behave.step("I execute dnf with args \"{args}\" {times} times")
def when_I_execute_dnf_with_args_times(context, args, times):
    for i in range(int(times)):
        context.execute_steps('when I execute dnf with args "{}"'.format(args))


@behave.step("I execute microdnf with args \"{args}\"")
def when_I_execute_microdnf_with_args(context, args):
    cmd = "microdnf"
    cmd += " " + args.format(context=context)
    context.dnf["rpmdb_pre"] = get_rpmdb_rpms(context.dnf.installroot)
    run_in_context(context, cmd, can_fail=True)


@behave.step("I execute rpm with args \"{args}\"")
def when_I_execute_rpm_with_args(context, args):
    cmd = "rpm --root=" + context.dnf.installroot
    cmd += " " + args.format(context=context)
    run_in_context(context, cmd, can_fail=True)


@behave.step("I execute rpm on host with args \"{args}\"")
def when_I_execute_rpm_on_host_with_args(context, args):
    cmd = "rpm"
    cmd += " " + args.format(context=context)
    run_in_context(context, cmd, can_fail=True)


@behave.step("I execute \"{command}\" in \"{directory}\"")
def when_I_execute_command_in_directory(context, command, directory):
    run_in_context(context, command.format(context=context), cwd=directory.format(context=context))


@behave.step("I execute \"{command}\"")
def when_I_execute_command(context, command):
    run_in_context(context, command.format(context=context))


@behave.given("I do not assume yes")
def given_I_do_not_assumeyes(context):
    context.dnf._set("assumeyes_option", "")


@behave.given("I do not set config file")
def step_impl(context):
    context.dnf._set("config", "")


@behave.given("I set config file to \"{configfile}\"")
def step_impl(context, configfile):
    full_path = os.path.join(context.dnf.installroot, configfile.lstrip("/"))
    context.dnf._set("config", full_path)


@behave.given("I do not set releasever")
def step_impl(context):
    context.dnf._set("releasever", "")


@behave.given("I do not disable plugins")
def step_impl(context):
    context.dnf._set("disable_plugins", False)


@behave.given("I enable plugin \"{plugin}\"")
def given_enable_plugin(context, plugin):
    if "plugins" not in context.dnf:
        context.dnf["plugins"] = []
    if plugin not in context.dnf["plugins"]:
        context.dnf["plugins"].append(plugin)


@behave.given("I successfully execute dnf with args \"{args}\"")
def given_i_successfully_execute_dnf_with_args(context, args):
    context.execute_steps(u"Given I execute dnf with args \"{args}\"".format(args=args))
    then_the_exit_code_is(context, 0)


@behave.given("I successfully execute rpm with args \"{args}\"")
def given_i_successfully_execute_rpm_with_args(context, args):
    context.execute_steps(u"Given I execute rpm with args \"{args}\"".format(args=args))
    then_the_exit_code_is(context, 0)


@behave.step("I set config option \"{option}\" to \"{value}\"")
def step_impl(context, option, value):
    if "setopts" not in context.dnf:
        context.dnf["setopts"] = {}
    context.dnf["setopts"][option] = value


@behave.then("the exit code is {exitcode}")
def then_the_exit_code_is(context, exitcode):
    if context.cmd_exitcode == int(exitcode):
        return
    raise AssertionError("Command has returned exit code {0}: {1}".format(context.cmd_exitcode, context.cmd))


@behave.then("stdout contains \"{text}\"")
def then_stdout_contains(context, text):
    if re.search(text.format(context=context), context.cmd_stdout):
        return
    raise AssertionError("Stdout doesn't contain: %s" % text)

@behave.then("stdout does not contain \"{text}\"")
def then_stdout_does_not_contain(context, text):
    if not re.search(text.format(context=context), context.cmd_stdout):
        return
    raise AssertionError("Stdout contains: %s" % text)


@behave.then("stdout is empty")
def then_stdout_is_empty(context):
    if not context.cmd_stdout:
        return
    raise AssertionError("Stdout is not empty, it contains: %s" % context.cmd_stdout)


@behave.then("stdout is")
def then_stdout_is(context):
    """
    Checks for the exact match of the test's stdout. Supports the <REPOSYNC>
    placeholder on the first line, which will match against the repository
    synchronization lines (i.e. the "Last metadata expiration check:" line as
    well as the individual repo download lines) in the test's output.
    """
    expected = context.text.format(context=context).strip().split('\n')
    found = context.cmd_stdout.strip().split('\n')

    if found == [""]:
        found = []

    clean_expected, clean_found = handle_reposync(expected, found)

    if clean_expected == clean_found:
        return

    rs_offset = 0
    if len(clean_expected) < len(expected):
        if len(clean_found) == len(found):
            rs_offset = 1
            # reposync was not in found, prepend a single line to pad for the
            # <REPOSYNC> line in expected
            found = [""] + found
        else:
            rs_offset = len(found) - len(clean_found)
            # prepend empty lines to expected to pad for multiple reposync
            # lines in found
            expected = [""] * (rs_offset - 1) + expected

    print_lines_diff(expected, found, num_lines_equal=rs_offset)

    raise AssertionError("Stdout is not: %s" % context.text)


@behave.then("stdout contains lines")
def then_stdout_contains_lines(context):
    out_lines = [l.strip() for l in context.cmd_stdout.split('\n')]
    test_lines = [l.strip() for l in context.text.split('\n')]
    for line in test_lines:
        for outline in out_lines:
            if line == outline:
                break
        else:
            raise AssertionError("Stdout doesn't contain line: %s" % line)


@behave.then("stdout does not contain lines")
def then_stdout_contains_lines(context):
    out_lines = [l.strip() for l in context.cmd_stdout.split('\n')]
    test_lines = [l.strip() for l in context.text.split('\n')]
    for line in test_lines:
        for outline in out_lines:
            if line == outline:
                raise AssertionError("Stdout contains line: %s" % line)


@behave.then('stdout section "{section}" contains "{regexp}"')
def then_stdout_section_contains(context, section, regexp):
    """Compares the content of a particular section from the command output with a given regexp"""
    section_content = extract_section_content_from_text(section, context.cmd_stdout)
    if re.search(regexp, section_content):
        return
    raise AssertionError("Stdout section %s doesn't contain: %s" % (section, regexp))


@behave.then("stderr is")
def then_stderr_is(context):
    expected = context.text.format(context=context).strip().split('\n')
    found = context.cmd_stderr.strip().split('\n')

    if expected == found:
        return

    print_lines_diff(expected, found)

    raise AssertionError("Stderr is not: %s" % context.text)


@behave.then("stderr contains \"{text}\"")
def then_stderr_contains(context, text):
    if re.search(text.format(context=context), context.cmd_stderr):
        return
    raise AssertionError("Stderr doesn't contain: %s" % text)


@behave.then("stderr does not contain \"{text}\"")
def then_stderr_contains(context, text):
    if not re.search(text.format(context=context), context.cmd_stderr):
        return
    raise AssertionError("Stderr contains: %s" % text)


@behave.then("stderr is empty")
def then_stderr_is_empty(context):
    if not context.cmd_stderr:
        return
    raise AssertionError("Stderr is not empty, it contains: %s" % context.cmd_stderr)


@behave.then("stderr contains lines")
def then_stdout_contains_lines(context):
    out_lines = context.cmd_stderr.split('\n')
    test_lines = context.text.split('\n')
    for line in test_lines:
        for outline in out_lines:
            if line.strip() == outline.strip():
                break
        else:
            raise AssertionError("Stderr doesn't contain line: %s" % line)


@behave.then("stdout matches line by line")
def then_stdout_matches_line_by_line(context):
    """
    Checks that each line of stdout matches respective line in regular expressions.
    Supports the <REPOSYNC> in the same way as the step "stdout is"
    """
    found = context.cmd_stdout.strip().split('\n')
    expected = context.text.strip().split('\n')

    clean_expected, clean_found = handle_reposync(expected, found)

    lines_match_to_regexps_line_by_line(clean_found, clean_expected)


@behave.then("stderr matches line by line")
def then_stderr_matches_line_by_line(context):
    out_lines = context.cmd_stderr.split('\n')
    regexp_lines = context.text.split('\n')
    lines_match_to_regexps_line_by_line(out_lines, regexp_lines)
