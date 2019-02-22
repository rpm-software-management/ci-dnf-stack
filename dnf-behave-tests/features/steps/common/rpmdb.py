# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import rpm

from .rpm import normalize_epoch
from .rpm import RPM


def get_rpmdb_rpms(installroot="/"):
    """
    Read all installed RPMs from RPM database.
    """
    result = set()
    ts = rpm.TransactionSet(installroot)
    for hdr in ts.dbMatch():
        name = hdr["name"].decode()
        arch = hdr["arch"]
        if name.startswith("gpg-pubkey"):
            continue
        decoded = dict(name=name,
                evr=normalize_epoch(hdr["evr"].decode()),
                arch=arch.decode() if arch is not None else None)
        result.add(RPM("{0[name]}-{0[evr]}.{0[arch]}".format(decoded), hdr))
    return result
