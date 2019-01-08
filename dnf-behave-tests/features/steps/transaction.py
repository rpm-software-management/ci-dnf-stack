import behave

from common import *


@behave.then("Transaction is following")
def then_Transaction_is_following(context):
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
            rpm = RPM(nevra)
            if action == "absent":
                if rpm in rpmdb_transaction["present"]:
                    raise AssertionError("[rpmdb] Package %s not '%s'" % (rpm, action))
                continue
            if rpm not in rpmdb_transaction[action]:
                candidates = ", ".join([str(i) for i in sorted(rpmdb_transaction[action])])
                raise AssertionError("[rpmdb] Package %s not '%s'; Possible candidates: %s" % (rpm, action, candidates))

    for rpmdb_action in sorted(rpmdb_transaction):
        if rpmdb_action in ["absent", "present", "unchanged", "changed"]:
            continue
        if rpmdb_action in ["downgraded", "upgraded"]:
            continue
        if rpmdb_action in ["broken"]:
            continue
        checked_nevras = checked_rpmdb.get(rpmdb_action, set())
        rpmdb_nevras = set([str(i) for i in rpmdb_transaction[rpmdb_action]])
        delta = rpmdb_nevras.difference(checked_nevras)
        if delta:
            raise AssertionError("Following packages weren't captured in the table for action '%s': %s" % (rpmdb_action, ", ".join(sorted(delta))))

    # check changes in DNF transaction table
    lines = context.cmd_stdout.splitlines()
    try:
        dnf_transaction = parse_transaction_table(lines)
    except RuntimeError:
        dnf_transaction = {}
    for action, nevras in context.table:
        for nevra in splitter(nevras):
            rpm = RPM(nevra)
            if action in ["absent", "present", "unchanged", "changed"]:
                continue
            if rpm not in dnf_transaction[action]:
                candidates = ", ".join([str(i) for i in sorted(dnf_transaction[action])])
                raise AssertionError("[dnf] Package %s not %s; Possible candidates: %s" % (rpm, action, candidates))


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
