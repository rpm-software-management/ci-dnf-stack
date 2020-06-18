# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave
import re

from common.lib.cmd import assert_exitcode
from common.lib.diff import print_lines_diff
from common.lib.text import lines_match_to_regexps_line_by_line


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


@behave.then("the exit code is {exitcode}")
def then_the_exit_code_is(context, exitcode):
    assert_exitcode(context, exitcode)


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
    expected = context.text.format(context=context).rstrip().split('\n')
    found = context.cmd_stdout.rstrip().split('\n')

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


@behave.then("stdout matches line by line")
def then_stdout_matches_line_by_line(context):
    """
    Checks that each line of stdout matches respective line in regular expressions.
    Supports the <REPOSYNC> in the same way as the step "stdout is"
    """
    found = context.cmd_stdout.split('\n')
    expected = context.text.split('\n')

    clean_expected, clean_found = handle_reposync(expected, found)

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
