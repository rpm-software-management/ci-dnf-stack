# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import rpm

from .cmd import run
from .rpm import normalize_epoch
from .rpm import RPM


def _get_hdr_str(hdr, name):
    try:
        return hdr[name].decode()
    except AttributeError:
        return hdr[name]


def get_rpmdb_rpms(installroot="/"):
    """
    Read all installed RPMs from RPM database.
    """
    result = set()
    ts = rpm.TransactionSet(installroot)
    for hdr in ts.dbMatch():
        name = _get_hdr_str(hdr, "name")
        if name.startswith("gpg-pubkey"):
            continue
        decoded = {
            "name": name,
            "evr": normalize_epoch(_get_hdr_str(hdr, "evr")),
            "arch": _get_hdr_str(hdr, "arch"),
        }
        result.add(RPM("{0[name]}-{0[evr]}.{0[arch]}".format(decoded), hdr))
    return result

