import rpm

from .cmd import run
from .rpm import normalize_epoch
from .rpm import RPM


def get_rpmdb_rpms(installroot="/"):
    """
    Read all installed RPMs from RPM database.
    """
    result = set()
    ts = rpm.TransactionSet(installroot)
    for hdr in ts.dbMatch():
        decoded = dict(name=hdr["name"].decode(),
                evr=normalize_epoch(hdr["evr"].decode()),
                arch=hdr["arch"].decode())
        if decoded["name"].startswith("gpg-pubkey"):
            continue
        result.add(RPM("{0[name]}-{0[evr]}.{0[arch]}".format(decoded), hdr))
    return result

