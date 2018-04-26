from __future__ import absolute_import
from __future__ import unicode_literals

import collections
import enum
import functools
import logging

import rpm

class State(enum.Enum):
    installed = "installed"
    removed = "removed"
    absent = "absent"
    unchanged = "unchanged"
    reinstalled = "reinstalled"
    updated = "updated"
    upgraded = "updated"
    downgraded = "downgraded"
    ignored = "ignored"

def get_rpmdb():
    """
    Get RPM Headers of all installed packages.

    Result is sorted by *name* (Python's default sorting) and EVR
    (:func:`rpm.versionCompare`).

    :return: RPM Headers
    :rtype: list(rpm.hdr)
    """
    pkgs = {}
    for hdr in rpm.TransactionSet().dbMatch():
        name = hdr["name"].decode()
        if name not in pkgs:
            pkgs[name] = []
        pkgs[name].append(hdr)
    pkgs = collections.OrderedDict(sorted(pkgs.items()))
    rpmdb = []
    for hdrs in pkgs.values():
        rpmdb.extend(sorted(hdrs, key=functools.cmp_to_key(rpm.versionCompare)))
    return rpmdb

def hdr2nevra(hdr):
    """
    :param rpm.hdr hdr: RPM Header
    :return: NEVRA
    :rtype: str
    """
    return hdr["nevra"].decode() if hdr else None

def find_pkg(pkgs, pkg, only_by_name=False):
    """
    :param list(rpm.hdr) pkgs: List of RPM Headers
    :param str pkg: Package to find
    :param bool only_by_name: Whether to ignore Epoch, Version, Release
    :return: First found RPM header
    :rtype: rpm.hdr or None
    """
    epoch = version = release = None
    if "/" in pkg:
        name, evr = pkg.split("/")
        if ":" in evr:
            epoch = evr.split(":", 1)[0]
            evr = evr[len(epoch) + 1:]
        if "-" in evr:
            version, release = evr.split("-")
        else:
            version = evr
    else:
        name = pkg

    for p in pkgs:
        if p.name.decode() != name:
            continue
        if only_by_name:
            return p
        if (epoch is None or p.epoch.decode() == epoch) and \
           (version is None or p.version.decode() == version) and \
           (release is None or p.release.decode() == release):
            return p
        else:
            logging.warning("Similar package to {!r}: {!r}".format(pkg, hdr2nevra(p)))
    return None

def analyze_state(pre, post):
    """
    Analyze state of packages.

    :param rpm.hdr pre: Header before
    :param rpm.hdr post: Header after
    :return: State
    :rtype: utils.State
    """
    if not pre and post:
        return State.installed
    if pre and not post:
        return State.removed
    if not pre and not post:
        return State.absent
    if pre["sha1header"] == post["sha1header"]:
        if pre.unload() == post.unload():
            return State.unchanged
        else:
            return State.reinstalled
    ver_cmp = rpm.versionCompare(pre, post)
    if ver_cmp < 0:
        return State.updated
    if ver_cmp > 0:
        return State.downgraded
    # In theory, it will never happen as sha1header should be different
    assert ver_cmp == 0

    pre_nevra = hdr2nevra(pre)
    post_nevra = hdr2nevra(post)

    # probably reinstalled from different repository
    if pre_nevra == post_nevra:
        return State.reinstalled

    # Most probably we just compare different packages
    assert False, "{!r} -> {!r}".format(pre_nevra, post_nevra)
