# -*- coding: utf-8 -*-

import hashlib
import os

from common.lib.file import decompress_file_by_extension

import bz2
import gzip
# xz compression
try:
    import lzma
except ImportError:
    from backports import lzma


def get_checksum_regex(type_str):
    if type_str == "sha256":
        return "[a-z0-9]{64}"
    if type_str == "sha224":
        return "[a-z0-9]{56}"
    if type_str == "sha512":
        return "[a-z0-9]{128}"
    if type_str == "-":
        return ""
    raise ValueError("Unknown checksum type: " + type_str)


def decompression_iter(filepath, compression_type, blocksize=65536):
    if compression_type == "gz":
        return file_as_blockiter(gzip.open(filepath, 'rb'), blocksize)
    if compression_type == "xz":
        return file_as_blockiter(lzma.open(filepath, 'rb'), blocksize)
    if compression_type == "bz2":
        return file_as_blockiter(bz2.open(filepath, 'rb'), blocksize)
    if compression_type == "zstd":
        decompress_file_by_extension_to_dir(filepath, os.path.dirname(filepath))
        return file_as_blockiter(open(filepath[:-4], 'rb'), blocksize)
    if compression_type == "zck":
        decompress_file_by_extension_to_dir(filepath, os.path.dirname(filepath))
        return file_as_blockiter(open(filepath[:-4], 'rb'), blocksize)

    return file_as_blockiter(open(filepath, 'rb'), blocksize)


def checksum_of_file(filepath, checksum_type="sha256"):
    if checksum_type == "sha256":
        return hash_bytestr_iter(file_as_blockiter(open(filepath, 'rb')), hashlib.sha256())
    if checksum_type == "sha224":
        return hash_bytestr_iter(file_as_blockiter(open(filepath, 'rb')), hashlib.sha224())
    if checksum_type == "sha512":
        return hash_bytestr_iter(file_as_blockiter(open(filepath, 'rb')), hashlib.sha512())
    raise ValueError("Unknown checksum type: " + checksum_type)


def hash_bytestr_iter(bytesiter, hasher, ashexstr=True):
    for block in bytesiter:
        hasher.update(block)
    return hasher.hexdigest() if ashexstr else hasher.digest()


def file_as_blockiter(afile, blocksize=65536):
    with afile:
        block = afile.read(blocksize)
        while len(block) > 0:
            yield block
            block = afile.read(blocksize)


def conmpress_extension_to_type(extension):
    if extension[0] == ".":
        extension = extension[1:]
    if extension in ("gz", "zck", "xz", "bz2"):
        return extension
    if extension == "zst":
        return "zstd"

    return ""


def decompress_file_by_extension_to_dir(compressed_filepath, dest_dir):
    content = decompress_file_by_extension(compressed_filepath)

    if content is None:
        return None

    basename = os.path.basename(compressed_filepath)
    dst = os.path.join(dest_dir, basename)
    dst = os.path.splitext(dst)[0] #remove compression extension

    open(dst, "wb").write(content)
    return dst
