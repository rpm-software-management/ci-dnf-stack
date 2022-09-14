# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave
import re
import parse

from common.lib.cmd import assert_exitcode
from common.lib.diff import print_lines_diff
from common.lib.text import lines_match_to_regexps_line_by_line


sync_line_dnf4 = re.compile(r".*[0-9.]+ +[kMG]?B/s \| +[0-9.]+ +[kMG]?B +[0-9]{2}:[0-9]{2}")
bottom_line_dnf4 = re.compile(r"Last metadata expiration check: .*")

def strip_reposync_dnf4(found_lines, line_number):
    while line_number < len(found_lines) and sync_line_dnf4.fullmatch(found_lines[line_number].strip()):
        found_lines.pop(line_number)

    if line_number < len(found_lines) and bottom_line_dnf4.fullmatch(found_lines[line_number].strip()):
        found_lines.pop(line_number)


sync_line_dnf5 = re.compile(
    r"\[[0-9]+/[0-9]+\] .* [0-9]+% \| +[0-9.]+ +[KMG]?i?B/s \| +[0-9.]+ +[KMG]?i?B \| + [0-9hms]+")

def strip_reposync_dnf5(found_lines, line_number):
    if line_number < len(found_lines) and found_lines[line_number].strip() == "Updating and loading repositories:":
        found_lines.pop(line_number)

    while line_number < len(found_lines) and sync_line_dnf5.fullmatch(found_lines[line_number].strip()):
        found_lines.pop(line_number)

    if line_number < len(found_lines) and found_lines[line_number].strip() == "Repositories loaded.":
        found_lines.pop(line_number)

def strip_help_dnf4(found_lines, line_number):
    pass

def strip_help_dnf5(found_lines, line_number):
    end_of_help_dnf5 = "--disableplugin=PLUGIN_NAME,...        Alias for '--disable-plugin'"
    if line_number < len(found_lines) and (found_lines[line_number].strip() == "Missing command" or found_lines[line_number].strip() == "Usage:" ):
        found_lines.pop(line_number)

    while line_number < len(found_lines) and found_lines[line_number].strip() != end_of_help_dnf5:
        found_lines.pop(line_number)

    if line_number < len(found_lines) and found_lines[line_number].strip() == end_of_help_dnf5:
        found_lines.pop(line_number)


def handle_reposync(expected, found, dnf5_mode):
    line_number = 0
    for line in expected:
        if line == "<REPOSYNC>":
            if dnf5_mode:
                strip_reposync_dnf5(found, line_number)
            else:
                strip_reposync_dnf4(found, line_number)

            expected.pop(line_number)
            break

        if line == "<HELP>":
            if dnf5_mode:
                strip_help_dnf5(found, line_number)
            else:
                strip_help_dnf4(found, line_number)

            expected.pop(line_number)
            break

        line_number += 1

    return expected, found


@behave.then("the exit code is {exitcode}")
def then_the_exit_code_is(context, exitcode):
    assert_exitcode(context, exitcode)


@behave.then("stdout is empty")
def then_stdout_is_empty(context):
    if not context.cmd_stdout:
        return
    raise AssertionError("Stdout is not empty, it contains: %s" % context.cmd_stdout)


@behave.then("stdout is help")
def then_stdout_is_help(context):
    expected = context.text.format(context=context).rstrip().split('\n')
    found = context.cmd_stdout.rstrip().split('\n')

    if found == [""]:
        found = []

    dnf5_mode = hasattr(context, "dnf5_mode") and context.dnf5_mode
    clean_expected, clean_found = handle_help(expected, found, dnf5_mode)

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


@behave.then("stdout is")
def then_stdout_is(context):
    """
    Checks for the exact match of the test's stdout. Supports the <REPOSYNC>
    placeholder on the first line, which will match against the repository
    synchronization lines (i.e. the "Last metadata expiration check:" line as
    well as the individual repo download lines) in the test's output.
    """
    expected = context.text.format(context=context).rstrip().split('\n')
    found = context.cmd_stdout.rstrip().split('\n')

    if found == [""]:
        found = []

    dnf5_mode = hasattr(context, "dnf5_mode") and context.dnf5_mode
    clean_expected, clean_found = handle_reposync(expected, found, dnf5_mode)

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


@parse.with_pattern(r"dnf4|dnf5")
def parse_dnf_version(text):
    return text
behave.register_type(dnf_version=parse_dnf_version)


@parse.with_pattern(r"stdout|stderr")
def parse_std_stream(text):
    return text
behave.register_type(std_stream=parse_std_stream)


@behave.then("stdout matches line by line")
def then_stdout_matches_line_by_line(context):
    """
    Checks that each line of stdout matches respective line in regular expressions.
    Supports the <REPOSYNC> in the same way as the step "stdout is"
    """
    found = context.cmd_stdout.split('\n')
    expected = context.text.split('\n')

    dnf5_mode = hasattr(context, "dnf5_mode") and context.dnf5_mode
    clean_expected, clean_found = handle_reposync(expected, found, dnf5_mode)

    lines_match_to_regexps_line_by_line(clean_found, clean_expected)


@behave.then("stderr is empty")
def then_stderr_is_empty(context):
    if not context.cmd_stderr:
        return
    raise AssertionError("Stderr is not empty, it contains: %s" % context.cmd_stderr)


@behave.then("stderr is")
def then_stderr_is(context):
    expected = context.text.format(context=context).strip().split('\n')
    found = context.cmd_stderr.strip().split('\n')

    if expected == found:
        return

    print_lines_diff(expected, found)

    raise AssertionError("Stderr is not: %s" % context.text)


@behave.then("stderr matches line by line")
def then_stderr_matches_line_by_line(context):
    out_lines = context.cmd_stderr.split('\n')
    regexp_lines = context.text.split('\n')
    lines_match_to_regexps_line_by_line(out_lines, regexp_lines)


@behave.then("{dnf_version:dnf_version} exit code is {exitcode}")
def then_dnf_exit_code_is(context, dnf_version, exitcode):
    """
    Check for the test's exit code only if running in the
    appropriate mode otherwise the step is skipped
    Produce the steps:
        then dnf4 exit code is
        then dnf5 exit code is
    """
    dnf5_mode = hasattr(context, "dnf5_mode") and context.dnf5_mode
    if dnf_version == "dnf5" and dnf5_mode:
        then_the_exit_code_is(context, exitcode)
    if dnf_version == "dnf4" and not dnf5_mode:
        then_the_exit_code_is(context, exitcode)


@behave.then("{dnf_version:dnf_version} {std_stream:std_stream} is")
def then_dnf_stream_is(context, dnf_version, std_stream):
    """
    Check for exact match of the test's stdout/stderr
    only if running in the appropriate mode otherwise
    the step is skipped.
    Produce the steps:
        then dnf4 stdout is
        then dnf4 stderr is
        then dnf5 stderr is
        then dnf5 stdout is
    """
    if std_stream == "stdout":
        then_stream_is = then_stdout_is
    if std_stream == "stderr":
        then_stream_is = then_stderr_is

    dnf5_mode = hasattr(context, "dnf5_mode") and context.dnf5_mode
    if dnf_version == "dnf5" and dnf5_mode:
        then_stream_is(context)
    if dnf_version == "dnf4" and not dnf5_mode:
        then_stream_is(context)


@behave.then("{dnf_version:dnf_version} {std_stream:std_stream} matches line by line")
def then_dnf_stream_matches_line_by_line(context, dnf_version, std_stream):
    """
    Checks that each line of stdout/stderr matches respective
    line in regular expressions.
    Supports the <REPOSYNC> in the same way as the step
    "stdout is"
    Works only if running in the appropriate mode otherwise
    the step is skipped.
    Produce the steps:
        then dnf4 stdout matches line by line
        then dnf4 stderr matches line by line
        then dnf5 stderr matches line by line
        then dnf5 stdout matches line by line
    """
    if std_stream == "stdout":
        then_stream_matches_line_by_line = then_stdout_matches_line_by_line
    if std_stream == "stderr":
        then_stream_matches_line_by_line = then_stderr_matches_line_by_line

    dnf5_mode = hasattr(context, "dnf5_mode") and context.dnf5_mode
    if dnf_version == "dnf5" and dnf5_mode:
        then_stream_matches_line_by_line(context)
    if dnf_version == "dnf4" and not dnf5_mode:
        then_stream_matches_line_by_line(context)


@behave.then("{dnf_version:dnf_version} {std_stream:std_stream} is empty")
def then_dnf_stream_is_empty(context, dnf_version, std_stream):
    """
    Check that stdout/stderr is empty
    Works only if running in the appropriate mode otherwise
    the step is skipped
    Produce the steps:
        then dnf4 stdout is empty
        then dnf4 stderr is empty
        then dnf5 stdout is empty
        then dnf5 stderr is empty
    """
    if std_stream == "stdout":
        then_stream_is_empty = then_stdout_is_empty
    if std_stream == "stderr":
        then_stream_is_empty = then_stderr_is_empty

    dnf5_mode = hasattr(context, "dnf5_mode") and context.dnf5_mode
    if dnf_version == "dnf5" and dnf5_mode:
        then_stream_is_empty(context)
    if dnf_version == "dnf4" and not dnf5_mode:
        then_stream_is_empty(context)

@behave.then("{dnf_version:dnf_version} stdout is help")
def then_dnf_stdout_is_help(context, dnf_version):
    """
    Check that stdout output is help message
    Works only if running in the appropriate mode otherwise
    the step is skipped
    Produce the steps:
        then dnf4 stdout is help
        then dnf5 stdout is help
    """
    dnf5_mode = hasattr(context, "dnf5_mode") and context.dnf5_mode
    if dnf_version == "dnf5" and dnf5_mode:
        then_stdout_is_help(context)
    if dnf_version == "dnf4" and not dnf5_mode:
        then_stdout_is_help(context)


