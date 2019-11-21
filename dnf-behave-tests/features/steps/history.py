# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave

from common.behave_ext import check_context_table
from common.cmd import run_in_context
from common.dnf import parse_history_info, parse_history_list


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
    IN = ['Command Line',]
    ACTIONS = ['Install', 'Removed', 'Upgrade', 'Upgraded', 'Reinstall', 'Downgrade']
    check_context_table(context, ["Key", "Value"])

    if spec is None:
        spec = ""
    h_info = parsed_history_info(context, spec)

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
            for pkg in value.split(','):
                for line in h_info[None]:
                    if key in line and pkg in line:
                        break
                else:
                    raise AssertionError(
                        '[history] "{0}" not matched as "{1}".'.format(pkg, key))
        else:
            raise AssertionError('[history] key "{0}" not found.'.format(key))

@behave.then('History info rpmdb version did not change')
def step_impl(context, spec=""):
    h_info = parsed_history_info(context, spec)
    assert (h_info['Begin rpmdb']), "End rpmdb version not found"
    assert (h_info['End rpmdb']), "End rpmdb version not found"
    assert (h_info['End rpmdb'] == h_info['Begin rpmdb']), "Begin and end rpmdb versions are different"

@then('history userinstalled should')
def step_impl(context):
    check_context_table(context, ["Action", "Package"])
    cmd = " ".join(context.dnf.get_cmd(context) + ["history", "userinstalled"])
    run_in_context(context, cmd)

    for action, package in context.table:
        if action == 'match':
            if package not in context.cmd_stdout:
                raise AssertionError(
                    '[history] package "{0}" not matched as userinstalled.'.format(package))
        elif action == 'not match':
            if package in context.cmd_stdout:
                raise AssertionError(
                    '[history] package "{0}" matched as userinstalled.'.format(package))
        else:
            raise ValueError('Invalid action "{0}".'.format(action))
