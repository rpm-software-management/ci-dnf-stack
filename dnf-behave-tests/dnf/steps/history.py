# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave
import re

from common.lib.behave_ext import check_context_table
from common.lib.cmd import run_in_context
from common.lib.diff import print_lines_diff
from lib.dnf import parse_history_info, parse_history_list


def parsed_history_info(context, spec):
    cmd = " ".join(context.dnf.get_cmd(context) + ["history", "info", spec])
    run_in_context(context, cmd)
    return parse_history_info(context.cmd_stdout.splitlines())


def assert_history_list(context, cmd_stdout):
    def history_equal(history, table):
        if table['Id'] and table['Id'] != history['id']:
            return False
        if table['Action'] and table['Action'] != history['action']:
            return False
        if table['Altered'] and table['Altered'] != history['altered']:
            return False
        if table['Command']:
            # command column in `history list` output is trimmed to limited space
            # to get full command, we need to ask `history info`
            h_info = parsed_history_info(context, history['id'])
            if not table['Command'] in h_info.get('Command Line', ''):
                return False
        return True

    check_context_table(context, ["Id", "Command", "Action", "Altered"])

    stdout_lines = cmd_stdout.splitlines()[2:]
    history = parse_history_list(stdout_lines)

    table_idx = 0
    for t_line in context.table:
        try:
            h_line = history[table_idx]
        except IndexError:
            print(cmd_stdout)
            raise AssertionError(
                "[history] table line (%s, %s, %s, %s) missing in history" % (
                    t_line['Id'], t_line['Command'], t_line['Action'], t_line['Altered']))
        if not history_equal(h_line, t_line):
            print(cmd_stdout)
            raise AssertionError(
                "[history] table line (%s, %s, %s, %s) does not match \"%s\"" % (
                    t_line['Id'], t_line['Command'], t_line['Action'], t_line['Altered'],
                    h_line['_line']))
        table_idx += 1

    if len(history) > table_idx:
        print(cmd_stdout)
        raise AssertionError(
            "[history] Following history lines not captured in the table:\n%s" % (
                '\n'.join(stdout_lines[table_idx:])))


@behave.then('stdout is history list')
def step_impl(context):
    assert_history_list(context, context.cmd_stdout)


@behave.then('History is following')
@behave.then('History "{history_range}" is following')
def step_impl(context, history_range=None):
    if history_range is None:
        history_range = "list"

    cmd = " ".join(context.dnf.get_cmd(context) + ["history", history_range])
    run_in_context(context, cmd)

    assert_history_list(context, context.cmd_stdout)


@behave.then('History info should match')
@behave.then('History info "{spec}" should match')
def step_impl(context, spec=None):
    IN = ['Description',]
    ACTIONS = [
        'Install',
        'Upgrade',
        'Downgrade',
        'Reinstall',
        'Remove',
        'Replaced',
        'Reason Change',
        'Enable',
        'Disable',
        'Reset',
    ]

    check_context_table(context, ["Key", "Value"])

    if spec is None:
        spec = ""
    h_info = parsed_history_info(context, spec)

    expected_actions = []
    for key, value in context.table:
        if key in h_info:
            if key in IN and value in h_info[key]:
                continue
            elif value == h_info[key]:
                continue
            else:
                raise AssertionError(
                    '[history] {0} "{1}" not matched by "{2}".'.format(
                        key, h_info[key], value))
        elif key in ACTIONS:
            expected_actions.append([key, value])
        else:
            raise AssertionError('[history] key "{0}" not found.'.format(key))

    found_actions = []
    for a in h_info[None]:
        action = a.split()

        if action[0:2] == ["Reason", "Change"]:
            found_actions.append(["Reason Change", action[2]])
        else:
            found_actions.append(action[0:2])

    if expected_actions != found_actions:
        print_lines_diff(expected_actions, found_actions)
        raise AssertionError("History actions mismatch")

@behave.then('History info rpmdb version changed')
def step_impl(context, spec=""):
    h_info = parsed_history_info(context, spec)
    assert (h_info['Begin rpmdb']), "End rpmdb version not found"
    assert (h_info['End rpmdb']), "End rpmdb version not found"
    assert (h_info['End rpmdb'] != h_info['Begin rpmdb']), "Begin and end rpmdb versions are the same"


@behave.then('package reasons are')
def step_impl(context):
    # we only do the check for dnf4
    if hasattr(context, "dnf5_mode") and context.dnf5_mode:
        return

    check_context_table(context, ["Package", "Reason"])

    cmd = context.dnf.get_cmd(context) + ["repoquery --qf '%{name}-%{evr}.%{arch},%{reason}' --installed"]

    run_in_context(context, " ".join(cmd))

    expected = [[p, r] for p, r in context.table]
    found = sorted([r.split(",") for r in context.cmd_stdout.strip().split('\n')])

    if found != expected:
        print_lines_diff(expected, found)
        raise AssertionError("Package reasons mismatch")


# Need to use this complex regex here, as both the first and the third column
# may contain spaces, and a space is also a column separator
transaction_item_re = re.compile("  (.+[^ ]) +(.+-[^ ]+) +(.+[^ ]+) +(.+)")

@behave.then('dnf5 transaction items for transaction "{id}" are')
def step_impl(context, id):
    # we only do the check for dnf5
    if hasattr(context, "dnf5_mode") and not context.dnf5_mode:
        return

    check_context_table(context, ["action", "package", "reason", "repository"])

    cmd = context.dnf.get_cmd(context) + ["history", "info", id]
    run_in_context(context, " ".join(cmd))

    expected = [(a, p, r, repo) for a, p, r, repo in context.table]
    found = []
    parse = False
    for line in context.cmd_stdout.strip().split('\n'):
        if not parse:
            if line.split() == ["Action", "Package", "Reason", "Repository"]:
                parse = True
            else:
                continue
        else:
            res = transaction_item_re.match(line)
            if res is not None:
                found.append(res.groups())

    if found != expected:
        print_lines_diff(expected, found)
        raise AssertionError("Package reasons mismatch")
