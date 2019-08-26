# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import re


SPLITTER_RE = re.compile(r", *")


def splitter(text):
    """
    Split text by ", "
    """
    return SPLITTER_RE.split(text)


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
