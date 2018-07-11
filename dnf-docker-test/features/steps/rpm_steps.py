from __future__ import absolute_import
from __future__ import unicode_literals

from behave import then
from behave import when
from behave.model import Table
from rpm_utils import State
import six
from six.moves import zip
import fnmatch

import rpm_utils
import table_utils

HEADINGS_RPMDB = ["State", "Packages"]

@when("I save rpmdb")
def step_i_save_rpmdb(ctx):
    """
    Save rpmdb headers into context to access/check at some point later.
    """
    ctx.rpmdb = rpm_utils.get_rpmdb()
    ctx.wipe_rpmdb = False

@then("rpmdb changes are")
def step_rpmdb_changes_are(ctx):
    """
    Compare saved by :ref:`When I save rpmdb` and current rpmdb's.

    Requires table with following headers:

    ======= ==========
     State   Packages 
    ======= ==========

    *State* is state of package

    ============ ============== ============= ===============================
       State      rpmdb before   rpmdb after        Additional comments      
    ============ ============== ============= ===============================
    installed    Not installed  Installed     Package has been installed     
    removed      Installed      Not installed Package has been removed       
    absent       Not installed  Not installed Package has not been installed 
    unchanged    Installed      Installed     Package was not changed        
    reinstalled  Installed      Installed     Same packages was reinstalled  
    updated      Installed      Installed     Package has been updated       
    downgraded   Installed      Installed     Package has been downgraded    
    ignored          -              -         Package will be ignored        
    ============ ============== ============= ===============================

    For each *State* you can specify multiple *Packages* which are separated
    by comma.

    For the *ignored* state you can use Unix shell-style wildcard to cover
    multiple package names. Packages with state explicitely stated won't be
    ignored even if they matches pattern.

    Examples:

    .. code-block:: gherkin

       Scenario: Detect reinstalled package
           When I save rpmdb
            And I successfully run "dnf -y reinstall util-linux"
           Then rpmdb changes are
             | State       | Packages   |
             | reinstalled | util-linux |

    .. code-block:: gherkin

       Scenario: Detect exact version
           When I save rpmdb
            And I successfully run "dnf -y update util-linux"
           Then rpmdb changes are
             | State   | Packages          |
             | updated | util-linux/2.29.0 |

    .. _automatic rules:

    **Automatic rules which are additionally applied**:

      - Packages except listed in table must not appear/disappear
      - Packages except listed in table classified as *unchanged*
    """
    ctx.assertion.assertIsNotNone(ctx.rpmdb, "Save rpmdb before comparison")
    table = table_utils.parse_kv_table(ctx, HEADINGS_RPMDB, rpm_utils.State)
    ctx.wipe_rpmdb = True
    rpmdb = rpm_utils.get_rpmdb()
    problems = []

    def unexpected_state(pkg, state, expected_state, pkg_pre, pkg_post):
        problems.append("Package {pkg!r} was supposed to be "
                        "{expected_state!r}, but has been {state!r} "
                        "({pkg_pre!r} -> {pkg_post!r})".format(
                            pkg=pkg, state=state.value,
                            expected_state=expected_state.value,
                            pkg_pre=rpm_utils.hdr2nevra(pkg_pre),
                            pkg_post=rpm_utils.hdr2nevra(pkg_post)))

    def pkgs_split(pkgs):
        for pkg in pkgs.split(","):
            yield pkg.strip()
    # Let's check what user has requested in table
    ignore_list = ""
    for expected_state, packages in table.items():
        if expected_state == rpm_utils.State.ignored:
            ignore_list = packages
        else:
            for pkg in pkgs_split(packages):
                pkg_pre = rpm_utils.find_pkg(ctx.rpmdb, pkg, only_by_name=True)
                if pkg_pre and rpm_utils.is_installonly_pkg(pkg_pre): # installonly package should match NVR
                    pkg_pre = rpm_utils.find_pkg(ctx.rpmdb, pkg, only_by_name=False)
                if pkg_pre:
                    ctx.rpmdb.remove(pkg_pre)
                pkg_post = rpm_utils.find_pkg(rpmdb, pkg)
                if pkg_post:
                    rpmdb.remove(pkg_post)
                state = rpm_utils.analyze_state(pkg_pre, pkg_post)
                if state != expected_state:
                    if state == State.unchanged and expected_state == State.reinstalled:
                        # workaround for unchanged rpmdb timestamp
                        text = getattr(ctx.cmd_result, 'stdout')
                        if "Reinstalling     : {}".format(pkg) in text:
                            continue
                    unexpected_state(pkg, state, expected_state, pkg_pre, pkg_post)

    # Now exclude packages matching regexp pattern in the ignore_list
    def filter_rpmdb(pkgs, filters):  # remove packages matching any filter
        remove = []
        for pkg in pkgs:
            for f in filters:
                if f and fnmatch.fnmatchcase(pkg.name, f):
                    remove.append(pkg)
                    break  # no need to process additional filters
        for pkg in remove:
            pkgs.remove(pkg)
    filter_rpmdb(rpmdb, list(pkgs_split(ignore_list)))
    filter_rpmdb(ctx.rpmdb, list(pkgs_split(ignore_list)))

    # Let's check if NEVRAs are still same
    def rpmdb2nevra(rpmdb):
        for hdr in rpmdb:
            yield rpm_utils.hdr2nevra(hdr)
    six.assertCountEqual(ctx.assertion,
                         rpmdb2nevra(ctx.rpmdb),
                         rpmdb2nevra(rpmdb))

    # Even if we have same NEVRAs packages can be different or reinstalled
    for pkg_pre, pkg_post in zip(ctx.rpmdb, rpmdb):
        state = rpm_utils.analyze_state(pkg_pre, pkg_post)
        expected_state = rpm_utils.State.unchanged
        # At this point pkg_pre and pkg_post should have same name
        pkg = pkg_pre["name"].decode()
        if state != expected_state:
            unexpected_state(pkg, state, expected_state, pkg_pre, pkg_post)

    assert not problems, "\n{!s}".format("\n".join(problems))

@then("rpmdb does not change")
def step_rpmdb_does_not_change(ctx):
    """
    Same as :ref:`Then rpmdb changes are`, but doesn't require table which
    means to apply only :ref:`rpmdb automatic rules <automatic rules>`.
    """
    ctx.table = Table(HEADINGS_RPMDB)
    step_rpmdb_changes_are(ctx)
