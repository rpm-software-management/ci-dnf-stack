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
        name = hdr["name"].decode()
        if name.startswith("gpg-pubkey"):
            continue
        decoded = dict(name=name,
                evr=normalize_epoch(hdr["evr"].decode()),
                arch=hdr["arch"].decode())
        result.add(RPM("{0[name]}-{0[evr]}.{0[arch]}".format(decoded), hdr))
    return result

