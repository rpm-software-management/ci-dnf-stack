# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave
from common.dnf import ACTIONS
from common.rpm import RPM

from common import *


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


def check_rpmdb_transaction(context, mode):
    check_context_table(context, ["Action", "Package"])

    if not "rpmdb_pre" in context.dnf:
        raise ValueError("RPMDB snapshot wasn't created before running this step.")

    context.dnf["rpmdb_post"] = get_rpmdb_rpms(context.dnf.installroot)

    checked_rpmdb = {}

    # check changes in RPMDB
    rpmdb_transaction = diff_rpm_lists(context.dnf["rpmdb_pre"], context.dnf["rpmdb_post"])
    for action, nevras in context.table:
        if action in ["broken"]:
            continue
        for nevra in nevras.split(", "):
            checked_rpmdb.setdefault(action, set()).add(nevra)
            if action.startswith('group-'):
                continue
            if action.startswith('module-'):
                continue
            rpm = RPM(nevra)
            if action == "reinstall" and rpm not in rpmdb_transaction["reinstall"]:
                action = "unchanged"
            if (action == "remove" and rpm not in rpmdb_transaction["remove"]
                and rpm in rpmdb_transaction["obsoleted"]):
                action = "obsoleted"
            elif (action == "obsoleted" and rpm not in rpmdb_transaction["obsoleted"]
                  and rpm in rpmdb_transaction["remove"]):
                action = "remove"
            if action == "absent":
                if rpm in rpmdb_transaction["present"]:
                    raise AssertionError("[rpmdb] Package %s not '%s'" % (rpm, action))
                continue
            if rpm not in rpmdb_transaction[action]:
                candidates = ", ".join([str(i) for i in sorted(rpmdb_transaction[action])])
                raise AssertionError("[rpmdb] Package %s not '%s'; Possible candidates: %s" % (
                                     rpm, action, candidates))

    if mode == 'exact_match':
        context_table = parse_context_table(context)
        for action in ["install", "remove", "upgrade", "downgrade"]:
            delta = []
            for nevra in context_table[action].copy():
                if nevra in rpmdb_transaction[action]:
                    rpmdb_transaction[action].remove(nevra)
                elif action == "remove": # and nevra in rpmdb_transaction["obsolete"]:
                    rpmdb_transaction["obsoleted"].remove(nevra)
                else:
                    delta.append(nevra)
            if delta:
                raise AssertionError(
                    "[rpmdb] Following packages weren't captured in the table for action '%s': %s" % (
                    action, ", ".join([str(rpm) for rpm in sorted(delta)])))


def check_dnf_transaction(context, mode):
    check_context_table(context, ["Action", "Package"])

    # check changes in DNF transaction table
    lines = context.cmd_stdout.splitlines()
    dnf_transaction = parse_transaction_table(lines)

    for action, nevras in context.table:
        if action in ["absent", "present", "unchanged", "changed"]:
            continue
        for nevra in nevras.split(", "):
            if action.startswith('group-') or action.startswith('module-'):
                title = action.split('-')[0].capitalize()
                group = nevra
                if group not in dnf_transaction[action]:
                    candidates = ", ".join([str(i) for i in sorted(dnf_transaction[action])])
                    raise AssertionError("[dnf] %s %s not %s; Possible candidates: %s" % (
                        title, group, action, candidates))
            else:
                rpm = RPM(nevra)
                if rpm not in dnf_transaction[action]:
                    candidates = ", ".join([str(i) for i in sorted(dnf_transaction[action])])
                    raise AssertionError("[dnf] Package %s not %s; Possible candidates: %s" % (
                                         rpm, action, candidates))

    if mode == 'exact_match':
        context_table = parse_context_table(context)
        for action, rpms in dnf_transaction.items():
            delta = rpms.difference(context_table[action])
            if delta:
                raise AssertionError(
                        "[dnf] Following packages weren't captured in the table for action '%s': %s" % (
                        action, ", ".join([str(rpm) for rpm in sorted(delta)])))


def check_transaction(context, mode):
    check_rpmdb_transaction(context, mode)
    check_dnf_transaction(context, mode)


@behave.then("Transaction is following")
def then_Transaction_is_following(context):
    check_transaction(context, 'exact_match')


@behave.then("RPMDB Transaction is following")
def then_RPMDB_Transaction_is_following(context):
    check_rpmdb_transaction(context, 'exact_match')


@behave.then("DNF Transaction is following")
def then_DNF_Transaction_is_following(context):
    check_dnf_transaction(context, 'exact_match')


@behave.then("Transaction contains")
def then_Transaction_contains(context):
    check_transaction(context, 'contains')


@behave.then("RPMDB Transaction is empty")
def then_RPMDB_transaction_is_empty(context):
    if not "rpmdb_pre" in context.dnf:
        raise ValueError("RPMDB snapshot wasn't created before running this step.")

    context.dnf["rpmdb_post"] = get_rpmdb_rpms(context.dnf.installroot)

    # check changes in RPMDB
    rpmdb_transaction = diff_rpm_lists(context.dnf["rpmdb_pre"], context.dnf["rpmdb_post"])
    if rpmdb_transaction["changed"]:
        changes = ", ".join([str(i) for i in sorted(rpmdb_transaction["changed"])])
        raise AssertionError("[rpmdb] Packages have changed: {}".format(changes))


@behave.then("DNF Transaction is empty")
def then_DNF_transaction_is_empty(context):
    # check changes in DNF transaction table
    lines = context.cmd_stdout.splitlines()
    try:
        dnf_transaction = parse_transaction_table(lines)
    except RuntimeError:
        dnf_transaction = {}
    if dnf_transaction:
        changes = ", ".join([str(i) for i in set().union(*dnf_transaction.values())])
        raise AssertionError("[dnf] Packages have changed: {}".format(changes))


@behave.then("Transaction is empty")
def then_transaction_is_empty(context):
    context.execute_steps(u"Then RPMDB Transaction is empty")
    context.execute_steps(u"Then DNF Transaction is empty")
