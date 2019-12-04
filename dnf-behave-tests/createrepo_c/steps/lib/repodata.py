# -*- coding: utf-8 -*-

import os
import re

from lib.file import checksum_of_file


def regex_find_file_from_list(filepath, files):
    filepath = filepath + '$'
    pattern = re.compile(os.path.basename(filepath))
    matched_files = list(filter(pattern.match, files))
    match_count = len(matched_files)
    if (match_count > 1):
        raise AssertionError("Multiple files matching: {0}, found:\n{1}" .format(filepath, '\n'.join(matched_files)))
    if (match_count <= 0):
        raise AssertionError("ENSURE: file exists \"{0}\", list contents"
                             " are:\n{1}".format(os.path.basename(filepath), "\n".join(files)))
    return os.path.join(os.path.dirname(filepath), matched_files[0])


def build_nevra(name, epoch, version, release, arch):
    nevra = name
    if version:
        nevra += '-'
        if epoch and epoch != '0':
            nevra += epoch + ':'
        nevra += version
        nevra += '-' + release
    if arch:
        nevra += '.' + arch
    return nevra


def verify_repomd_item_with_file(item, filepath, decompressed_filepath):
    compressed_checksum = checksum_of_file(filepath, item.checksum_type)
    if compressed_checksum != item.checksum:
        raise AssertionError("Checksum of File: " + filepath + " doesn't match checksum in the repomd.xml")
    compressed_stats = os.stat(filepath)
    if compressed_stats.st_size != int(item.size):
        raise AssertionError("Size of File: " + filepath + " doesn't match size in the repomd.xml")
    if decompressed_filepath:
        checksum = checksum_of_file(decompressed_filepath, item.checksum_type)
        if checksum != item.open_checksum:
            raise AssertionError("Checksum of decompressed File: " + decompressed_filepath + " doesn't"
                                 " match open checksum in the repomd.xml")
        compressed_stats = os.stat(decompressed_filepath)
        if compressed_stats.st_size != int(item.open_size):
            raise AssertionError("Size of decompressed File: " + decompressed_filepath + " doesn't"
                                 " match size in the repomd.xml")

    a = int(compressed_stats.st_mtime)
    b = int(item.timestamp)
    # We allow for some rounding error
    if (a < b - 1 or a > b + 1):
        raise AssertionError("Timestamp of File: " + filepath + " doesn't match"
                             "timestamp in the repomd.xml:\n" + str(a) + " vs. " + str(b))
