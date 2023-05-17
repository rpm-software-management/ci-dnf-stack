# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave
import os
import re
import sys
import time
from datetime import datetime

from common.lib.cmd import assert_exitcode, run_in_context
from common.lib.file import prepend_installroot
from fixtures import start_server_based_on_type
from lib.rpmdb import get_rpmdb_rpms


def get_boot_time():
    """Return the boot time of this system (as a timestamp)."""
    return int(os.stat('/proc/1/cmdline').st_mtime)

def extract_section_content_from_text(section_header, text):
    SECTION_HEADERS = [
            'Installing:', 'Upgrading:', 'Removing:', 'Downgrading:', 'Installing dependencies:',
            'Removing unused dependencies:', # dnf install/remove... transaction listing
            'Installed:', 'Upgraded:', 'Removed:', 'Downgraded:', 'New leaves:' # dnf install/remove/... result
            'Installed Packages', 'Available Packages', 'Recently Added Packages' # dnf list
            ]
    parsed = ''
    copy = False
    for line in text.split('\n'):
        if (not copy) and section_header == line:
            copy = True
            continue
        if copy:  # copy lines until hitting empty line or another known header
            if line.strip() and line not in SECTION_HEADERS:
                parsed += "%s\n" % line
            else:
                return parsed
    return parsed


@behave.step("I execute step \"{step}\"")
def execute_step(context, step):
    context.execute_steps(step)


@behave.step("I set environment variable \"{var}\" to \"{value}\"")
def set_environment_variable(context, var, value):
    os.environ[var] = value


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


@behave.step("I fake kernel release to {release}")
def i_fake_kernel_release(context, release):
    """Override uname() system call to return {release} as release.

    This is useful for faking running kernel, because libdnf determines running kernel in the
    following way:
        1. makes uname syscall to get operation system release
        2. searches for file "/boot/vmlinuz-<release>" (<release> from previous step)
        3. searches for RPM that provides that file
           -> this RPM is considered the running kernel

    Note that libdnf only checks running kernel when not running in installroot, therefore,
    @no_installroot tag is needed.

    By faking uname.release, all that remains to create fake running-kernel package is for the
    RPM to provide file "/boot/vmlinuz-{release}". (Do not forget to add the file into the %files
    section in the .spec file. It can be specified as %ghost for easier build.)

    :param release: arbitrary string
    """
    assert os.path.exists('/usr/bin/fakeuname'), (
        'Fakeuname binary must be installed (provided by fakeuname from '
        'rpmsoftwaremanagement/dnf-nightly copr repo)')
    context.fake_kernel_release = "fakeuname {} ".format(release)


@behave.step("I stop faking kernel release")
def i_stop_faking_kernel_release(context):
    """Cancels the effect of "I fake kernel release to {release}" step."""
    context.fake_kernel_release = None


@behave.step("I execute dnf with args \"{args}\"")
def when_I_execute_dnf_with_args(context, args):
    cmd = " ".join(context.dnf.get_cmd(context))
    cmd += " " + args.format(context=context)
    context.dnf["rpmdb_pre"] = get_rpmdb_rpms(context.dnf.installroot)
    run_in_context(context, cmd, can_fail=True)


@behave.step("I execute {dnf_version:dnf_version} with args \"{args}\"")
def when_I_execute_dnf_variant_with_args(context, dnf_version, args):
    dnf5_mode = hasattr(context, "dnf5_mode") and context.dnf5_mode
    if dnf_version == "dnf5" and dnf5_mode:
        when_I_execute_dnf_with_args(context, args)
    if dnf_version == "dnf4" and not dnf5_mode:
        when_I_execute_dnf_with_args(context, args)


@behave.step("I execute dnf with args \"{args}\" as an unprivileged user")
def when_I_execute_dnf_with_args_unprivileged(context, args):
    """
    Creates an unpriviged user if it doesn't exist (therefore the test is
    destructive!). Runs the dnf command under this user.
    """
    # create a regular user for the test if it doesn't exist
    run_in_context(context, 'id -u testuser || useradd testuser', can_fail=False)

    cmd = " ".join(context.dnf.get_cmd(context))
    cmd += " " + args.format(context=context)
    context.dnf["rpmdb_pre"] = get_rpmdb_rpms(context.dnf.installroot)

    # escape the quotes so that we can wrap the command in `su`
    cmd = cmd.replace('"', '\\"')
    run_in_context(context, 'su testuser -c "' + cmd + '"', can_fail=True)


@behave.step("I execute dnf with args \"{args}\" {times} times")
def when_I_execute_dnf_with_args_times(context, args, times):
    for i in range(int(times)):
        context.execute_steps('when I execute dnf with args "{}"'.format(args))


@behave.step("I execute microdnf with args \"{args}\"")
def when_I_execute_microdnf_with_args(context, args):
    cmd = " ".join(context.dnf.get_microdnf_cmd(context))
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


@behave.step("I execute dnf-automatic with args \"{args}\"")
def when_I_execute_dnf_automatic_with_args(context, args):
    cmd = "dnf-automatic"
    cmd += " " + args.format(context=context)
    context.dnf["rpmdb_pre"] = get_rpmdb_rpms(context.dnf.installroot)
    run_in_context(context, cmd, can_fail=True)


@behave.given("I do not assume yes")
def given_I_do_not_assumeyes(context):
    context.dnf._set("assumeyes_option", "")


@behave.given("I do not set releasever")
def step_impl(context):
    context.dnf._set("releasever", "")


@behave.given("I do not disable plugins")
def step_impl(context):
    context.dnf._set("disable_plugins", False)


@behave.given("I set dnf command to \"{command}\"")
def step_set_dnf_command(context, command):
    context.dnf.dnf_command = command


@behave.given("I enable plugin \"{plugin}\"")
def given_enable_plugin(context, plugin):
    if "plugins" not in context.dnf:
        context.dnf["plugins"] = []
    if plugin not in context.dnf["plugins"]:
        context.dnf["plugins"].append(plugin)


@behave.given("I successfully execute dnf with args \"{args}\"")
def given_i_successfully_execute_dnf_with_args(context, args):
    context.execute_steps(u"Given I execute dnf with args \"{args}\"".format(args=args))
    assert_exitcode(context, 0)


@behave.given("I successfully execute microdnf with args \"{args}\"")
def given_i_successfully_execute_microdnf_with_args(context, args):
    context.execute_steps(u"Given I execute microdnf with args \"{args}\"".format(args=args))
    assert_exitcode(context, 0)


@behave.given("I successfully execute rpm with args \"{args}\"")
def given_i_successfully_execute_rpm_with_args(context, args):
    context.execute_steps(u"Given I execute rpm with args \"{args}\"".format(args=args))
    assert_exitcode(context, 0)


@behave.step("I set config option \"{option}\" to \"{value}\"")
def step_impl(context, option, value):
    if "setopts" not in context.dnf:
        context.dnf["setopts"] = {}
    context.dnf["setopts"][option] = value


@behave.step('I set up a http server for directory "{path}"')
def step_set_up_http_server(context, path):
    full_path = prepend_installroot(context, path)
    host, port = start_server_based_on_type(context, full_path, 'http')
    context.dnf.ports[path] = port


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
def then_stdout_does_not_contain_lines(context):
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


@behave.then('stdout section "{section}" does not contain "{regexp}"')
def then_stdout_section_does_not_contain(context, section, regexp):
    section_content = extract_section_content_from_text(section, context.cmd_stdout)
    if re.search(regexp, section_content):
        raise AssertionError("Stdout section %s contains: %s" % (section, regexp))


@behave.then("stderr contains \"{text}\"")
def then_stderr_contains(context, text):
    if re.search(text.format(context=context), context.cmd_stderr):
        return
    raise AssertionError("Stderr doesn't contain: %s" % text)


@behave.then("stderr does not contain \"{text}\"")
def then_stderr_does_not_contain(context, text):
    if not re.search(text.format(context=context), context.cmd_stderr):
        return
    raise AssertionError("Stderr contains: %s" % text)


@behave.then("stderr contains lines")
def then_stderr_contains_lines(context):
    out_lines = context.cmd_stderr.split('\n')
    test_lines = context.text.split('\n')
    for line in test_lines:
        for outline in out_lines:
            if line.strip() == outline.strip():
                break
        else:
            raise AssertionError("Stderr doesn't contain line: %s" % line)


@behave.then("{dnf_version:dnf_version} {std_stream:std_stream} contains \"{text}\"")
def then_dnf_stream_contains(context, dnf_version, std_stream, text):
    """
    Check that stdout/stderr contains some text
    Works only if running in the appropriate mode otherwise
    the step is skipped
    Produce the steps:
        then dnf4 stdout contains
        then dnf4 stderr contains
        then dnf5 stdout contains
        then dnf5 stderr contains
    """
    if std_stream == "stdout":
        then_stream_contains = then_stdout_contains
    if std_stream == "stderr":
        then_stream_contains = then_stderr_contains

    dnf5_mode = hasattr(context, "dnf5_mode") and context.dnf5_mode
    if dnf_version == "dnf5" and dnf5_mode:
        then_stream_contains(context, text)
    if dnf_version == "dnf4" and not dnf5_mode:
        then_stream_contains(context, text)


@behave.then("{dnf_version:dnf_version} {std_stream:std_stream} does not contain \"{text}\"")
def then_dnf_stream_does_not_contain(context, dnf_version, std_stream, text):
    """
    Check that stdout/stderr does not contain some text
    Works only if running in the appropriate mode otherwise
    the step is skipped
    Produce the steps:
        then dnf4 stdout does not contain
        then dnf4 stderr does not contain
        then dnf5 stdout does not contain
        then dnf5 stderr does not contain
    """
    if std_stream == "stdout":
        then_stream_does_not_contain = then_stdout_does_not_contain
    if std_stream == "stderr":
        then_stream_does_not_contain = then_stderr_does_not_contain

    dnf5_mode = hasattr(context, "dnf5_mode") and context.dnf5_mode
    if dnf_version == "dnf5" and dnf5_mode:
        then_stream_does_not_contain(context, text)
    if dnf_version == "dnf4" and not dnf5_mode:
        then_stream_does_not_contain(context, text)


@behave.then("{dnf_version:dnf_version} {std_stream:std_stream} contains lines")
def then_dnf_stream_contains_lines(context, dnf_version, std_stream):
    """
    Check that stdout/stderr contains lines
    Works only if running in the appropriate mode otherwise
    the step is skipped
    Produce the steps:
        then dnf4 stdout contains lines
        then dnf4 stderr contains lines
        then dnf5 stdout contains lines
        then dnf5 stderr contains lines
    """
    if std_stream == "stdout":
        then_stream_contains_lines = then_stdout_contains_lines
    if std_stream == "stderr":
        then_stream_contains_lines = then_stderr_contains_lines

    dnf5_mode = hasattr(context, "dnf5_mode") and context.dnf5_mode
    if dnf_version == "dnf5" and dnf5_mode:
        then_stream_contains_lines(context)
    if dnf_version == "dnf4" and not dnf5_mode:
        then_stream_contains_lines(context)


@behave.then("{dnf_version:dnf_version} {std_stream:std_stream} does not contain lines")
def then_dnf_stream_does_not_contain_lines(context, dnf_version, std_stream):
    """
    Check that stdout/stderr does not contain lines
    Works only if running in the appropriate mode otherwise
    the step is skipped
    Produce the steps:
        then dnf4 stdout does not contain lines
        then dnf4 stderr does not contain lines
        then dnf5 stdout does not contain lines
        then dnf5 stderr does not contain lines
    """
    if std_stream == "stdout":
        then_stream_does_not_contain_lines = then_stdout_does_not_contain_lines
    if std_stream == "stderr":
        then_stream_does_not_contain_lines = then_stderr_does_not_contain_lines

    dnf5_mode = hasattr(context, "dnf5_mode") and context.dnf5_mode
    if dnf_version == "dnf5" and dnf5_mode:
        then_stream_contains_lines(context)
    if dnf_version == "dnf4" and not dnf5_mode:
        then_stream_contains_lines(context)


@behave.step("I sleep for \"{duration:d}\" seconds")
def step_sleep(context, duration):
    time.sleep(duration)
