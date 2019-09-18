# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

from .dnf import ACTIONS
from .rpm import RPM

def check_context_table(context, headings):
    if not context.table:
        raise ValueError("Table not specified.")

    if context.table.headings != headings:
        raise ValueError("Invalid table headings. Expected: %s" % ", ".join(headings))

def parse_context_table(context):
    result = {}
    for action in ACTIONS.values():
        result[action] = []
    result["obsoleted"] = []

    for action, nevras in context.table:
        if action not in result:
            continue
        if action.startswith('group-') or action.startswith('module-'):
            for group in nevras.split(", "):
                result[action].append(group)
        else:
            for nevra in nevras.split(", "):
                rpm = RPM(nevra)
                result[action].append(rpm)

    return result
