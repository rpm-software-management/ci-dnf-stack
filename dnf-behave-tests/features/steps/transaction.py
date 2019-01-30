import behave

from common import *


def check_transaction(context, mode):
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
        for nevra in splitter(nevras):
            checked_rpmdb.setdefault(action, set()).add(nevra)
            if action.startswith('group-'):
                continue
            if action == "reinstall":
                action = "unchanged"
            rpm = RPM(nevra)
            if action == "absent":
                if rpm in rpmdb_transaction["present"]:
                    raise AssertionError("[rpmdb] Package %s not '%s'" % (rpm, action))
                continue
            if rpm not in rpmdb_transaction[action]:
                candidates = ", ".join([str(i) for i in sorted(rpmdb_transaction[action])])
                raise AssertionError("[rpmdb] Package %s not '%s'; Possible candidates: %s" % (
                                     rpm, action, candidates))

    # check changes in DNF transaction table
    lines = context.cmd_stdout.splitlines()
    try:
        dnf_transaction = parse_transaction_table(lines)
    except RuntimeError:
        dnf_transaction = {}
        for action in ACTIONS.values():
            dnf_transaction[action] = set()
    for action, nevras in context.table:
        if action in ["absent", "present", "unchanged", "changed"]:
            continue
        for nevra in splitter(nevras):
            if action.startswith('group-'):
                group = nevra
                if group not in dnf_transaction[action]:
                    candidates = ", ".join([str(i) for i in sorted(dnf_transaction[action])])
                    raise AssertionError("[dnf] Group %s not %s; Possible candidates: %s" % (
                                         group, action, candidates))
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
                        "Following packages weren't captured in the table for action '%s': %s" % (
                        action, ", ".join([str(rpm) for rpm in sorted(delta)])))


@behave.then("Transaction is following")
def then_Transaction_is_following(context):
    check_transaction(context, 'exact_match')

@behave.then("Transaction contains")
def then_Transaction_contains(context):
    check_transaction(context, 'contains')


@behave.then("Transaction is empty")
def then_transaction_is_empty(context):
    if not "rpmdb_pre" in context.dnf:
        raise ValueError("RPMDB snapshot wasn't created before running this step.")

    context.dnf["rpmdb_post"] = get_rpmdb_rpms(context.dnf.installroot)

    # check changes in RPMDB
    rpmdb_transaction = diff_rpm_lists(context.dnf["rpmdb_pre"], context.dnf["rpmdb_post"])
    if rpmdb_transaction["changed"]:
        changes = ", ".join([str(i) for i in sorted(rpmdb_transaction["changed"])])
        raise AssertionError("[rpmdb] Packages have changed: {}".format(changes))

    # check changes in DNF transaction table
    lines = context.cmd_stdout.splitlines()
    try:
        dnf_transaction = parse_transaction_table(lines)
    except RuntimeError:
        dnf_transaction = {}
    if dnf_transaction:
        changes = ", ".join([str(i) for i in set().union(*dnf_transaction.values())])
        raise AssertionError("[dnf] Packages have changed: {}".format(changes))
