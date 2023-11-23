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
from common.lib.diff import print_lines_diff
from common.lib.file import get_compression_suffix

from lib.sqlite_repodata import load_sqlite
from lib.xml_repodata import xml_parse_repodata
from lib.repodata import regex_find_file_from_list
from lib.repodata import verify_repomd_item_with_file
from lib.repodata import build_nevra
from lib.file import get_checksum_regex
from lib.file import decompression_iter
from lib.file import checksum_of_file

from string import Template


# namespaces
ns = {"pri_ns": "http://linux.duke.edu/metadata/common",
      "fil_ns": "http://linux.duke.edu/metadata/filelists",
      "oth_ns": "http://linux.duke.edu/metadata/other",
      "md_ns": "http://linux.duke.edu/metadata/repo"}


def keys_do_not_differ(prim, flist, oth):
    if prim.keys() != flist.keys():
        print_lines_diff(prim.keys(), flist.keys())
        raise AssertionError("Primary and Filelists have different package sets.")
    if prim.keys() != oth.keys():
        print_lines_diff(prim.keys(), oth.keys())
        raise AssertionError("Primary and Other have different package sets.")


def repodata_do_not_differ(prim1, prim2, flist1, flist2, oth1, oth2):
    # Compare packages by checksums
    if prim1.keys() != prim2.keys():
        print_lines_diff(prim1.keys(), prim2.keys())
        raise AssertionError("Primary repodata have different package sets.")

    # Compare packages by name
    if prim1.packages() != prim2.packages():
        print_lines_diff(prim1.packages(), prim2.packages())
        raise AssertionError("Primary repodata have different sets of package names.")

    diff = prim1.diff(prim2)
    if diff:
        raise AssertionError("Primary repodata are different.\n"
                             "Difference: %s" % (diff))
    diff = flist1.diff(flist2)
    if diff:
        raise AssertionError("Filelists repodata are different.\n"
                             "Difference: %s" % (diff))
    diff = oth1.diff(oth2)
    if diff:
        raise AssertionError("Other repodata are different.\n"
                             "Difference: %s" % (diff))


@behave.step("repodata \"{path}\" are consistent")
def repodata_are_consistent(context, path):
    repopath = os.path.join(context.tempdir_manager.tempdir, path.lstrip('/'))
    tmpdir = tempfile.mkdtemp()
    prim_path_sqlite = None
    prim_zck_path = None

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

        if item.name == "primary_db":
            prim_path_sqlite = decompressed_p
        elif item.name == "filelists_db":
            filelists_path_sqlite = decompressed_p
        elif item.name == "other_db":
            other_path_sqlite = decompressed_p
        elif item.name == "primary":
            prim_path = decompressed_p
        elif item.name == "filelists":
            filelists_path = decompressed_p
        elif item.name == "other":
            other_path = decompressed_p
        elif item.name == "primary_zck":
            prim_zck_path = decompressed_p
        elif item.name == "filelists_zck":
            filelists_zck_path = decompressed_p
        elif item.name == "other_zck":
            other_zck_path = decompressed_p
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

    keys_do_not_differ(primary, filelists, other)

    # SQLITE
    if prim_path_sqlite: # All three sqlite files have to be present at the same time
        primary_sql = load_sqlite(prim_path_sqlite, "primary")
        filelists_sql = load_sqlite(filelists_path_sqlite, "filelists")
        other_sql = load_sqlite(other_path_sqlite, "other")

        keys_do_not_differ(primary_sql, filelists_sql, other_sql)
        repodata_do_not_differ(primary, primary_sql, filelists, filelists_sql, other, other_sql)

    # ZCK
    if prim_zck_path: # All three zck files have to be present at the same time
        primary_zck = xml_parse_repodata(prim_zck_path, "{%s}package" % ns["pri_ns"], "primary")
        filelists_zck = xml_parse_repodata(filelists_zck_path, "{%s}package" % ns["fil_ns"], "filelists")
        other_zck = xml_parse_repodata(other_zck_path, "{%s}package" % ns["oth_ns"], "other")

        keys_do_not_differ(primary_zck, filelists_zck, other_zck)
        repodata_do_not_differ(primary, primary_zck, filelists, filelists_zck, other, other_zck)

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
            if compression_suffix and filepath.endswith(compression_suffix):
                filepath = filepath[:-(len(compression_suffix))]
            if tmp:
                if filepath.endswith(".sqlite"):
                    assert ("SQLite" in str(tmp))
                elif filepath.endswith(".xml"):
                    assert ("xml" in str(tmp))
                elif filepath.endswith(".yaml"):
                    # Assume all yaml files are modulemd documents
                    assert ("modulemd" in str(tmp))
                elif filepath.endswith(".txt"):
                    pass
                else:
                    raise
        except (AssertionError, IOError):
            raise AssertionError("Cannot decompress File: " + repodata_file + " using"
                                 " compression type: " + compression_type)

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
