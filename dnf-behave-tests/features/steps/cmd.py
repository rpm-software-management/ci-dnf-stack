# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import os
import re
import sys
from datetime import datetime
from itertools import zip_longest

import behave

from common import *


def print_cmd(context, cmd, stdout, stderr):
    if cmd:
        print('Command: DNF0={} {}\n'.format(context.dnf.fixturesdir, context.cmd))
    if stdout:
        print(context.cmd_stdout)
    if stderr:
        print(context.cmd_stderr, file=sys.stderr)


def print_diff(expected, found, reposync_lines=0):
    left_width = len("expected")

    # calculate the width of the left column
    for line in expected:
        left_width = max(len(line), left_width)

    print("{:{left_width}}  |  {}".format("expected", "found", left_width=left_width))

    green, red, reset = "\033[1;32m", "\033[1;31m", "\033[0;0m"

    for line in zip_longest(expected, found, fillvalue=""):
        col = green if reposync_lines > 0 or line[0] == line[1] else red
        print("{}{:{left_width}}  |  {}{}".format(col, line[0], line[1], reset, left_width=left_width))
        reposync_lines -= 1


@behave.step("I execute step \"{step}\"")
def execute_step(context, step):
    context.execute_steps(step)


@behave.step("I move the clock {direction} to \"{when}\"")
def faketime(context, direction, when):
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

@behave.step("I execute dnf with args \"{args}\" from repo \"{repo}\"")
def when_I_execute_dnf_with_args_from_repo(context, repo, args):
    repodir = os.path.join(context.dnf.repos_location, repo)

    cmd = " ".join(context.dnf.get_cmd(context))
    cmd += " " + args.format(context=context)
    context.dnf["rpmdb_pre"] = get_rpmdb_rpms(context.dnf.installroot)
    context.cmd = cmd
    context.cmd_exitcode, context.cmd_stdout, context.cmd_stderr = run(
        cmd, shell=True, cwd=repodir)


@behave.step("I execute dnf with args \"{args}\"")
def when_I_execute_dnf_with_args(context, args):
    cmd = " ".join(context.dnf.get_cmd(context))
    cmd += " " + args.format(context=context)
    context.dnf["rpmdb_pre"] = get_rpmdb_rpms(context.dnf.installroot)
    if getattr(context, "faketime", None) is not None:
        cmd = context.faketime + cmd
    context.cmd = cmd
    context.cmd_exitcode, context.cmd_stdout, context.cmd_stderr = run(cmd, shell=True)


@behave.step("I execute rpm with args \"{args}\"")
def when_I_execute_rpm_with_args(context, args):
    cmd = "rpm --root=" + context.dnf.installroot
    cmd += " " + args.format(context=context)
    context.cmd = cmd
    context.cmd_exitcode, context.cmd_stdout, context.cmd_stderr = run(cmd, shell=True)


@behave.step("I execute rpm on host with args \"{args}\"")
def when_I_execute_rpm_with_args(context, args):
    cmd = "rpm"
    cmd += " " + args.format(context=context)
    context.cmd = cmd
    context.cmd_exitcode, context.cmd_stdout, context.cmd_stderr = run(cmd, shell=True)


@behave.step("I execute bash with args \"{args}\" in directory \"{cwd}\"")
def step_impl(context, args, cwd):
    cwd = cwd.format(context=context)
    cmd = args.format(context=context)
    context.cmd = cmd
    context.cmd_exitcode, context.cmd_stdout, context.cmd_stderr = run(
        cmd, shell=True, can_fail=False, cwd=cwd)


@behave.given("I do not disable all repos")
def given_I_do_not_disable_all_repos(context):
    context.dnf._set("disable_repos_option", "")


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


@behave.given("I do not set reposdir")
def step_impl(context):
    context.dnf._set("reposdir", "")


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


@behave.step("I execute \"{command}\" with args \"{args}\"")
def when_I_execute_command_with_args(context, command, args):
    cmd = command + " " + args.format(context=context)
    context.cmd = cmd
    context.cmd_exitcode, context.cmd_stdout, context.cmd_stderr = run(cmd, shell=True)


@behave.step("I set config option \"{option}\" to \"{value}\"")
def step_impl(context, option, value):
    if "setopts" not in context.dnf:
        context.dnf["setopts"] = {}
    context.dnf["setopts"][option] = value


@behave.then("the exit code is {exitcode}")
def then_the_exit_code_is(context, exitcode):
    if context.cmd_exitcode == int(exitcode):
        return
    print_cmd(context, True, True, True)
    raise AssertionError("Command has returned exit code {0}: {1}".format(context.cmd_exitcode, context.cmd))


@behave.then("stdout contains \"{text}\"")
def then_stdout_contains(context, text):
    if re.search(text, context.cmd_stdout):
        return
    print_cmd(context, True, True, False)
    raise AssertionError("Stdout doesn't contain: %s" % text)

@behave.then("stdout does not contain \"{text}\"")
def then_stdout_does_not_contain(context, text):
    if not re.search(text, context.cmd_stdout):
        return
    print_cmd(context, True, True, False)
    raise AssertionError("Stdout contains: %s" % text)


@behave.then("stdout is empty")
def then_stdout_is_empty(context):
    if not context.cmd_stdout:
        return
    print_cmd(context, True, True, False)
    raise AssertionError("Stdout is not empty, it contains: %s" % context.cmd_stdout)


@behave.then("stdout is")
def then_stdout_is(context):
    expected = context.text.strip().split('\n')
    found = context.cmd_stdout.strip().split('\n')

    i = 0
    sync_line = re.compile(r".*[0-9.]+ +[kMG]?B/s \| +[0-9.]+ +[kMG]?B +[0-9]{2}:[0-9]{2}")
    last_check_line = re.compile(r"Last metadata expiration check: .*")
    if expected[0] == "<REPOSYNC>":
        while i < len(found) and (
                sync_line.fullmatch(found[i].strip())
                or last_check_line.fullmatch(found[i].strip())):
            i += 1

        expected.pop(0)

        found = found[i:]

    if expected == found:
        return

    expected = context.text.strip().split('\n')
    found = context.cmd_stdout.strip().split('\n')

    # prepend empty lines to pad for the reposync lines
    if i > 1:
        expected = [""] * (i - 1) + expected

    print_cmd(context, True, True, False)
    print_diff(expected, found, reposync_lines=i)

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
            print_cmd(context, True, True, False)
            raise AssertionError("Stdout doesn't contain line: %s" % line)


@behave.then("stdout matches each line once")
def then_stdout_matches_lines(context):
    out_lines = context.cmd_stdout.split('\n')
    test_lines = [l.strip() for l in context.text.split('\n')]
    for line in test_lines:
        for outline in out_lines:
            if re.search(line, outline):
                out_lines.remove(outline)
                break
        else:
            print_cmd(context, True, True, False)
            raise AssertionError("Stdout doesn't contain line: %s" % line)


@behave.then("stdout does not contain lines")
def then_stdout_contains_lines(context):
    out_lines = [l.strip() for l in context.cmd_stdout.split('\n')]
    test_lines = [l.strip() for l in context.text.split('\n')]
    for line in test_lines:
        for outline in out_lines:
            if line == outline:
                print_cmd(context, True, True, False)
                raise AssertionError("Stdout contains line: %s" % line)


@behave.then('stdout section "{section}" contains "{regexp}"')
def then_stdout_section_contains(context, section, regexp):
    """Compares the content of a particular section from the command output with a given regexp"""
    section_content = extract_section_content_from_text(section, context.cmd_stdout)
    if re.search(regexp, section_content):
        return
    print_cmd(context, True, True, False)
    raise AssertionError("Stdout section %s doesn't contain: %s" % (section, regexp))


@behave.then("stderr is")
def then_stderr_is(context):
    if context.text.strip() == context.cmd_stderr.strip():
        return
    print_cmd(context, True, False, True)
    raise AssertionError("Stderr is not: %s" % context.text)


@behave.then("stderr contains \"{text}\"")
def then_stderr_contains(context, text):
    if re.search(text, context.cmd_stderr):
        return
    print_cmd(context, True, False, True)
    raise AssertionError("Stderr doesn't contain: %s" % text)


@behave.then("stderr does not contain \"{text}\"")
def then_stderr_contains(context, text):
    if not re.search(text, context.cmd_stderr):
        return
    print_cmd(context, True, False, True)
    raise AssertionError("Stderr contains: %s" % text)


@behave.then("stderr is empty")
def then_stderr_is_empty(context):
    if not context.cmd_stderr:
        return
    print_cmd(context, True, False, True)
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
            print_cmd(context, True, False, True)
            raise AssertionError("Stderr doesn't contain line: %s" % line)


@behave.then("stdout matches line by line")
def then_stdout_matches_line_by_line(context):
    out_lines = context.cmd_stdout.split('\n')
    regexp_lines = context.text.split('\n')
    lines_match_to_regexps_line_by_line(out_lines, regexp_lines)


@behave.then("stderr matches line by line")
def then_stderr_matches_line_by_line(context):
    out_lines = context.cmd_stderr.split('\n')
    regexp_lines = context.text.split('\n')
    lines_match_to_regexps_line_by_line(out_lines, regexp_lines)
