import os

import behave

from common import *


@behave.step("the installroot path \"{path}\" does NOT exist")
def the_installroot_path_does_not_exist(context, path):
    full_path = os.path.join(context.dnf.installroot, path.lstrip("/"))
    if os.path.exists(full_path):
        raise AssertionError("Path exists: '%s'" % full_path)


@behave.step("the installroot path \"{path}\" exists")
def the_installroot_path_exists(context, path):
    full_path = os.path.join(context.dnf.installroot, path.lstrip("/"))
    if not os.path.exists(full_path):
        raise AssertionError("Path does not exist: '%s'" % full_path)


@behave.then("file sha256 checksums are following")
def then_file_sha256_checksums_are_following(context):
    check_context_table(context, ["Path", "sha256"])

    for path, checksum in context.table:
        # allow {context.dnf.tempdir} substitution
        path = path.format(context=context)

        # "-" checksum indicates that file must not exist
        if checksum == "-":
            if os.path.isfile(path):
                raise AssertionError("An unexpected file found on disk: %s" % path)
            else:
                continue

        file_checksum = sha256_checksum(open(path, "rb").read())

        # when 'file://<path>' is provided instead of the checksum,
        # the sha256 value is computed from that file
        if checksum.startswith("file://"):
            checksum_path = checksum[7:]
            checksum_path = checksum_path.format(context=context)
            checksum = sha256_checksum(open(path, "rb").read())

        if file_checksum != checksum:
            raise AssertionError("File sha256 checksum doesn't match (expected: %s, actual: %s): %s" % (checksum, file_checksum, path))
