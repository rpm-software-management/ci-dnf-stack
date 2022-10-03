# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave
import os
import toml

from common.lib.behave_ext import check_context_table
from common.lib.diff import print_lines_diff
from lib.rpm import RPM


@behave.then('package state is')
def package_state_is(context):
    """
    Checks the reason in system state packages.toml as well as the from_repo
    attribute from nevras.toml in one step. For that, the table in context has
    to contain the full NEVRA, which is converted to NA for checking the
    reason.

    The reason column also supports value of "None" which represents no
    record for the given NA.

    For installonly packages, multiple NEVRAS for the same NA can be put into
    the table, the reason is checked just as one NA record in packages.toml.
    """
    # we only do the check for dnf5
    if not hasattr(context, "dnf5_mode") or not context.dnf5_mode:
        return

    check_context_table(context, ["package", "reason", "from_repo"])

    found_pkgs = []
    with open(os.path.join(context.dnf.installroot, "usr/lib/sysimage/libdnf5/packages.toml")) as f:
        for k, v in toml.load(f)["packages"].items():
            found_pkgs.append((k, v["reason"]))
    found_pkgs.sort()

    found_nevras = []
    with open(os.path.join(context.dnf.installroot, "usr/lib/sysimage/libdnf5/nevras.toml")) as f:
        for k, v in toml.load(f)["nevras"].items():
            found_nevras.append((k, v["from_repo"]))
    found_nevras.sort()

    expected_pkgs_dict = {}
    expected_nevras = []
    for package, reason, from_repo in context.table:
        if reason != "None":
            na = RPM(package).na
            if na in expected_pkgs_dict and expected_pkgs_dict[na] != reason:
                raise AssertionError("Inconsistent reason for NA \"{}\"".format(na))
            expected_pkgs_dict[na] = reason

        expected_nevras.append((package, from_repo))

    expected_pkgs = sorted(expected_pkgs_dict.items())
    expected_nevras.sort()

    fail = False
    if expected_pkgs != found_pkgs:
        print("packages.toml system state differs from expected:")
        print_lines_diff(expected_pkgs, found_pkgs)
        fail = True

    if expected_nevras != found_nevras:
        print("nevras.toml system state differs from expected:")
        print_lines_diff(expected_nevras, found_nevras)
        fail = True

    if fail:
        raise AssertionError("System state mismatch")
