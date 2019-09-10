# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import re

import sys
PY3 = sys.version_info.major >= 3
if PY3:
    from itertools import zip_longest
else:
    from itertools import izip_longest as zip_longest


def print_lines_diff(expected, found, num_lines_equal=0):
    """ Prints a colored diff of two lists of strings.

    Parameters:
        expected: list of strings expected to find
        found: list of strings found
        num_lines_equal: a number that says how many strings at the beginning
            treat as equal even if they differ; a hack for correctly diffing
            outputs with repository syncing
    """
    left_width = len("expected")

    # calculate the width of the left column
    for line in expected:
        left_width = max(len(line), left_width)

    print("{:{left_width}}  |  {}".format("expected", "found", left_width=left_width))

    green, red, reset = "\033[1;32m", "\033[1;31m", "\033[0;0m"

    for line in zip_longest(expected, found, fillvalue=""):
        col = green if num_lines_equal > 0 or line[0] == line[1] else red
        print("{}{:{left_width}}  |  {}{}".format(col, line[0], line[1], reset, left_width=left_width))
        num_lines_equal -= 1


def extract_section_content_from_text(section_header, text):
    SECTION_HEADERS = [
            'Installing:', 'Upgrading:', 'Removing:', 'Downgrading:', 'Installing dependencies:',
            'Removing unused dependencies:', # dnf install/remove... transaction listing
            'Installed:', 'Upgraded:', 'Removed:', 'Downgraded:', # dnf install/remove/... result
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


def lines_match_to_regexps_line_by_line(out_lines, regexp_lines):
    """Matches list of lines against a list of regexps line by line"""
    while out_lines:
        line = out_lines.pop(0)
        if line and (not regexp_lines):  # there is no remaining regexp
            raise AssertionError("Not having a regexp to match line '%s'" % line)
        elif regexp_lines:
            regexp = regexp_lines.pop(0).strip()
            while regexp.startswith('?'):
                if not re.search(regexp[1:], line):  # optional regexp that doesn't need to be matched
                    if regexp_lines:
                        regexp = regexp_lines.pop(0).strip()
                    else:
                        raise AssertionError("Not having a regexp to match line '%s'" % line)
                else:
                    regexp = regexp[1:]
            if regexp:
                if not re.search(regexp, line):
                    raise AssertionError("'%s' regexp does not match line: '%s'" % (regexp, line))

            else:
                if not line == "":
                    raise AssertionError("'%s' is not empty line" % line)

    if regexp_lines:  # there are some unprocessed regexps
        raise AssertionError("No more line to match regexp '%s'" % regexp_lines[0])
