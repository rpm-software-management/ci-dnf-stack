import rpm

from .cmd import run
from .rpm import RPM


def get_rpmdb_rpms(installroot="/"):
    """
    Read all installed RPMs from RPM database.
    """

    cmd = [
        "rpm",
        "--root=%s" % installroot,
        "-qa",
        "--queryformat=%{name}-%|epoch?{%{epoch}:}:{0:}|%{version}-%{release}.%{arch}\n",
    ]
    _, stdout, _ = run(cmd, can_fail=False)
    result = set()
    for nevra in stdout.splitlines():
        if nevra.startswith("gpg-pubkey"):
            continue
        result.add(RPM(nevra))
    return result

