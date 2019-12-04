# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

import behave
import re
import os
import tempfile
import glob

from lib.file import decompress_file_by_extension_to_dir
from common.lib.behave_ext import check_context_table

from lib.sqlite_repodata import load_sqlite
from lib.xml_repodata import xml_parse_repodata
from lib.repodata import regex_find_file_from_list
from lib.repodata import verify_repomd_item_with_file
from lib.repodata import build_nevra
from lib.file import get_checksum_regex
from lib.file import get_compression_suffix
from lib.file import decompression_iter
from lib.file import checksum_of_file

from string import Template


# namespaces
ns = {"pri_ns": "http://linux.duke.edu/metadata/common",
      "fil_ns": "http://linux.duke.edu/metadata/filelists",
      "oth_ns": "http://linux.duke.edu/metadata/other",
      "md_ns": "http://linux.duke.edu/metadata/repo"}


@behave.step("repodata \"{path}\" are consistent")
def repodata_are_consistent(context, path):
    repopath = os.path.join(context.tempdir_manager.tempdir, path.lstrip('/'))
    tmpdir = tempfile.mkdtemp()
    prim_path_sqlite = None

    # REPOMD
    md_path = os.path.join(repopath, "repomd.xml")
    if not os.path.exists(md_path):
        raise AssertionError("Error: repomd.xml is missing (%s)" % md_path)

    repomd = xml_parse_repodata(md_path, "{%s}data" % ns["md_ns"], "repomd")
    for key in repomd.keys():
        item = repomd.items[key]
        if not item.location_href:
            continue
        # Remove /repodata/ from path
        basename = os.path.basename(item.location_href)
        p = os.path.join(repopath, basename.lstrip('/'))
        if not os.path.isfile(p):
            raise AssertionError("Error: repomd.xml contains: \"%s\""
                                 "but it is not present in %s" % (p, repopath))

        decompressed_p = decompress_file_by_extension_to_dir(p, tmpdir)

        if "primary_db" == item.name:
            prim_path_sqlite = decompressed_p
        elif "filelists_db" == item.name:
            filelists_path_sqlite = decompressed_p
        elif "other_db" == item.name:
            other_path_sqlite = decompressed_p
        elif "primary" == item.name:
            prim_path = decompressed_p
        elif "filelists" == item.name:
            filelists_path = decompressed_p
        elif "other" == item.name:
            other_path = decompressed_p
        else:
            # Skip unsupported updateinfo, comps, etc..
            # TODO(amatej): we could technically check for updateinfo,
            # comps, modules and even verify some stuff
            continue

        verify_repomd_item_with_file(item, p, decompressed_p)

    # XML
    primary = xml_parse_repodata(prim_path, "{%s}package" % ns["pri_ns"], "primary")
    filelists = xml_parse_repodata(filelists_path, "{%s}package" % ns["fil_ns"], "filelists")
    other = xml_parse_repodata(other_path, "{%s}package" % ns["oth_ns"], "other")

    if set(primary.keys()) != set(filelists.keys()):
        raise AssertionError("XML files Primary and Filelists have different package sets")
    if set(primary.keys()) != set(other.keys()):
        raise AssertionError("XML files Primary and Other have different package sets")

    # SQLITE
    if prim_path_sqlite: # All three sqlite files have to be present at the same time
        primary_sql = load_sqlite(prim_path_sqlite, "primary")
        filelists_sql = load_sqlite(filelists_path_sqlite, "filelists")
        other_sql = load_sqlite(other_path_sqlite, "other")

        if set(primary_sql.keys()) != set(filelists_sql.keys()):
            raise AssertionError("SQLITE files Primary and Filelists have different package sets.")
        if set(primary_sql.keys()) != set(other_sql.keys()):
            raise AssertionError("SQLITE files Primary and Other have different package sets.")

        # Compare XML vs SQLITE packages by checksums
        if primary.keys() != primary_sql.keys():
            raise AssertionError("SQLITE Primary and XML Primary have different package sets.")
        if filelists.keys() != filelists_sql.keys():
            raise AssertionError("SQLITE Filelists and XML Filelists have different package sets.")
        if other.keys() != other_sql.keys():
            raise AssertionError("SQLITE Other and XML Other have different package sets.")

        # Compare XML vs SQLITE packages by name, names in SQLITE are only in Primary
        if primary.packages() != primary_sql.packages():
            raise AssertionError("SQLITE Primary and XML Primary have different package sets.")

        diff = primary.diff(primary_sql)
        if diff:
            raise AssertionError("SQLITE Primary and XML Primary are different.\n"
                                 "Difference: %s" % (diff))
        diff = filelists.diff(filelists_sql)
        if diff:
            raise AssertionError("SQLITE Filelists and XML Filelists are different.\n"
                                 "Difference: %s" % (diff))
        diff = other.diff(other_sql)
        if diff:
            raise AssertionError("SQLITE Filelists and XML Filelists are different.\n"
                                 "Difference: %s" % (diff))
    return


@behave.step("repodata in \"{path}\" is")
def repodata_in_path_is(context, path):
    check_context_table(context, ["Type", "File", "Checksum Type", "Compression Type"])

    # repomd.xml is mandatory in this form
    repomd_filepath = os.path.join(context.tempdir_manager.tempdir, path.lstrip("/"), "repomd.xml")
    if not os.path.exists(repomd_filepath):
        raise AssertionError("Error: repomd.xml is missing (%s)" % repomd_filepath)

    files = os.listdir(os.path.dirname(repomd_filepath))
    files.remove("repomd.xml")

    for repodata_type, repodata_file, checksum_type, compression_type in context.table:
        checksum_regex = get_checksum_regex(checksum_type)

        filename_parts = repodata_file.split("-")

        if (len(filename_parts) == 1):
            pass # Simple-md-filenames
        elif (filename_parts[0] == "${checksum}"):
            filename_parts[0] = Template(filename_parts[0]).substitute(checksum=checksum_regex)
        else:
            if checksum_regex:
                if not (re.compile(checksum_regex + "$")).match(filename_parts[0]):
                    raise ValueError("Checksum type: " + checksum_type + " does not"
                                     " match to File: " + repodata_file)

        filepath = os.path.join(context.tempdir_manager.tempdir, path.lstrip("/"), '-'.join(filename_parts))
        # Final path to file, even when specified as regex
        # At the same time verifies that file exists
        filepath = regex_find_file_from_list(filepath, files)
        files.remove(os.path.basename(filepath))

        # Verify checksum
        checksum = checksum_of_file(filepath, checksum_type)
        if (checksum_regex):
            filename_parts_final = os.path.basename(filepath).split("-")
            if (len(filename_parts_final) == 1):
                pass # Simple-md-filenames
            elif not checksum == filename_parts_final[0]:
                raise ValueError("Checksum of File: " + repodata_file + " doesn't match checksum"
                                 " in the name of the File: " + os.path.basename(filepath))

        # Verify compression
        compression_suffix = get_compression_suffix(compression_type)
        if compression_suffix:
            if not filepath.endswith(compression_suffix):
                raise ValueError("Compression type: " + compression_type + " does"
                                 " not match suffix of File: " + repodata_file)
        try:
            tmp = next(decompression_iter(filepath, compression_type, blocksize=100))
            if tmp:
                if filepath.endswith(".zck"):
                    assert("ZCK" in str(tmp))
                elif filepath.endswith(".sqlite"):
                    assert("SQLITE" in str(tmp))
                elif filepath.endswith(".xml"):
                    assert("xml" in str(tmp))
                else:
                    pass
                    # We don't know the filetype, assume it's correct
        except (AssertionError, IOError):
            raise AssertionError("Cannot decompress File: " + repodata_file + " using"
                                 " copression type: " + compression_type)

    if len(files) > 0:
        raise AssertionError("repodata directory contains additional metadata files:\n{0}".format('\n'.join(files)))


@behave.step("primary in \"{path}\" has only packages")
def primary_in_path_contains_only_packages(context, path):
    check_context_table(context, ["Name", "Epoch", "Version", "Release", "Architecture"])
    filepath = os.path.join(context.tempdir_manager.tempdir, path.lstrip('/'), "*-primary.xml.*")
    primary_filepath = glob.glob(filepath)[0]
    primary = xml_parse_repodata(primary_filepath, "{%s}package" % ns["pri_ns"], "primary")

    for name, epoch, version, release, architecture in context.table:
        nevra = build_nevra(name, epoch, version, release, architecture)
        found = False
        for key in primary.keys():
            pkg = primary.items[key]
            if (nevra == pkg.nevra()):
                del primary.items[key]
                found = True
                break

        if not found:
            print("primary.xml yet unmatched packages:")
            for key in primary.keys():
                pkg = primary.items[key]
                print("\t" + build_nevra(pkg.name, pkg.epoch, pkg.version, pkg.release, pkg.arch))
            raise AssertionError("Package " + nevra + " not found")

    if (len(primary.keys()) > 0):
        print("primary.xml contains additional packages:")
        for key in primary.keys():
            pkg = primary.items[key]
            print("\t" + build_nevra(pkg.name, pkg.epoch, pkg.version, pkg.release, pkg.arch))
        raise AssertionError("Additional packages in primary.xml")


@behave.step("primary in \"{path}\" doesn't have any packages")
def primary_in_path_doesnt_contain_any_packages(context, path):
    filepath = os.path.join(context.tempdir_manager.tempdir, path.lstrip('/'), "*-primary.xml.*")
    primary_filepath = glob.glob(filepath)[0]
    primary = xml_parse_repodata(primary_filepath, "{%s}package" % ns["pri_ns"], "primary")

    if (len(primary.keys()) > 0):
        print("primary.xml contains additional packages:")
        for key in primary.keys():
            pkg = primary.items[key]
            print("\t" + build_nevra(pkg.name, pkg.epoch, pkg.version, pkg.release, pkg.arch))
        raise AssertionError("Additional packages in primary.xml")
