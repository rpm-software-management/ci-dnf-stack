import behave

from common import *


@behave.then("Transaction is following")
def then_Transaction_is_following(context):
    check_context_table(context, ["Action", "Package"])

    if not "rpmdb_pre" in context.dnf:
        raise ValueError("RPMDB snapshot wasn't created before running this step.")

    context.dnf["rpmdb_post"] = get_rpmdb_rpms(context.dnf.installroot)

    # check changes in RPMDB
    rpmdb_transaction = diff_rpm_lists(context.dnf["rpmdb_pre"], context.dnf["rpmdb_post"])
    for action, nevras in context.table:
        for nevra in splitter(nevras):
            rpm = RPM(nevra)
            if action == "absent":
                if rpm in rpmdb_transaction["present"]:
                    raise AssertionError("[rpmdb] Package %s not '%s'" % (rpm, action))
                continue
            if rpm not in rpmdb_transaction[action]:
                candidates = ", ".join([str(i) for i in sorted(rpmdb_transaction[action])])
                raise AssertionError("[rpmdb] Package %s not '%s'; Possible candidates: %s" % (rpm, action, candidates))

    # check changes in DNF transaction table
    lines = context.cmd_stdout.splitlines()
    try:
        dnf_transaction = parse_transaction_table(lines)
    except RuntimeError:
        dnf_transaction = {}
    for action, nevras in context.table:
        for nevra in splitter(nevras):
            rpm = RPM(nevra)
            if action in ["absent", "present", "unchanged"]:
                continue
            if rpm not in dnf_transaction[action]:
                candidates = ", ".join([str(i) for i in sorted(dnf_transaction[action])])
                raise AssertionError("[dnf] Package %s not %s; Possible candidates: %s" % (rpm, action, candidates))


@behave.then("Transaction is empty")
def then_transaction_is_empty(context):
    context.dnf["rpmdb_post"] = get_rpmdb_rpms(context.dnf.installroot)
    rpmdb_transaction = diff_rpm_lists(context.dnf["rpmdb_pre"], context.dnf["rpmdb_post"])
    if rpmdb_transaction["present"]:
        changes = ", ".join([str(i) for i in sorted(dnf_transaction["changed"])])
        raise AssertionError("[rpmdb] Packages have changed: {}".format(changes))
