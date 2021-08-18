# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import print_function

from lib.repodata_representation import Metadata
from lib.repodata_representation import PrimaryPackage
from lib.repodata_representation import FilelistsPackage
from lib.repodata_representation import OtherPackage
from lib.repodata_representation import RepomdItem

from lib.file import decompression_iter
from lib.file import conmpress_extension_to_type

import os
import xml.etree.ElementTree as ET


def _parse_pco(elem, requires=False):
    req_set = set([])
    for felem in elem:
        if felem.tag.endswith("entry"):
            res = (felem.get("name"),
                   felem.get("flags"),
                   felem.get("epoch"),
                   felem.get("ver"),
                   felem.get("rel"))
            if requires:
                res += (bool(int(felem.get("pre", 0))),)
        req_set.add(res)
    return req_set


def xml_parse_repodata(repodata_path, element_tag, repodata_type):
    file_extension = os.path.splitext(repodata_path)[1]
    iterator = decompression_iter(repodata_path, conmpress_extension_to_type(file_extension))

    if repodata_type == "primary":
        parse_pkg_elem = parse_primary_pkg_elem
    elif repodata_type == "filelists":
        parse_pkg_elem = parse_filelists_pkg_elem
    elif repodata_type == "other":
        parse_pkg_elem = parse_other_pkg_elem
    elif repodata_type == "repomd":
        parse_pkg_elem = parse_repomd_item_elem

    parser = ET.XMLPullParser(['end'])
    metadata_obj = Metadata(repodata_path)
    for xml_data in iterator:
        parser.feed(xml_data)
        for event, element in parser.read_events():
            if event == "end" and element.tag == element_tag:
                pp = parse_pkg_elem(element)
                metadata_obj.append(pp.checksum, pp)
    return metadata_obj


def parse_primary_pkg_elem(element):
    pp = PrimaryPackage()
    for pkg_elem in element.iter(None):
        if pkg_elem.tag.endswith("name"):
            pp.name = pkg_elem.text
        elif pkg_elem.tag.endswith("arch"):
            pp.arch = pkg_elem.text
        elif pkg_elem.tag.endswith("version"):
            pp.epoch = pkg_elem.get("epoch")
            pp.version = pkg_elem.get("ver")
            pp.release = pkg_elem.get("rel")
        elif pkg_elem.tag.endswith("checksum"):
            pp.checksum_type = pkg_elem.get("type")
            pp.checksum = pkg_elem.text
        elif pkg_elem.tag.endswith("summary"):
            pp.summary = pkg_elem.text
        elif pkg_elem.tag.endswith("description"):
            pp.description = pkg_elem.text
        elif pkg_elem.tag.endswith("packager"):
            pp.packager = pkg_elem.text
        elif pkg_elem.tag.endswith("url"):
            pp.url = pkg_elem.text
        elif pkg_elem.tag.endswith("time"):
            pp.time_file = int(pkg_elem.get("file"))
            pp.time_build = int(pkg_elem.get("build"))
        elif pkg_elem.tag.endswith("size"):
            pp.size_package = int(pkg_elem.get("package"))
            pp.size_installed = int(pkg_elem.get("installed"))
            pp.size_archive = int(pkg_elem.get("archive"))
        elif pkg_elem.tag.endswith("location"):
            pp.location = pkg_elem.get("href")
            pp.location_base = pkg_elem.get("{http://www.w3.org/XML/1998/namespace}base")
        elif pkg_elem.tag.endswith("format"):
            for fpkg_elem in pkg_elem.iter(None):
                if fpkg_elem.tag.endswith("license"):
                    pp.license = fpkg_elem.text
                elif fpkg_elem.tag.endswith("vendor"):
                    pp.vendor = fpkg_elem.text
                elif fpkg_elem.tag.endswith("group"):
                    pp.group = fpkg_elem.text
                elif fpkg_elem.tag.endswith("buildhost"):
                    pp.buildhost = fpkg_elem.text
                elif fpkg_elem.tag.endswith("sourcerpm"):
                    pp.sourcerpm = fpkg_elem.text
                elif fpkg_elem.tag.endswith("header-range"):
                    pp.header_start = int(fpkg_elem.get("start"))
                    pp.header_end = int(fpkg_elem.get("end"))
                elif fpkg_elem.tag.endswith("provides"):
                    pp.provides = _parse_pco(fpkg_elem)
                elif fpkg_elem.tag.endswith("conflicts"):
                    pp.conflicts = _parse_pco(fpkg_elem)
                elif fpkg_elem.tag.endswith("obsoletes"):
                    pp.obsoletes = _parse_pco(fpkg_elem)
                elif fpkg_elem.tag.endswith("requires"):
                    pp.requires = _parse_pco(fpkg_elem, requires=True)
                elif fpkg_elem.tag.endswith("file"):
                    if fpkg_elem.get("type") == "dir":
                        pp.dirs.add(fpkg_elem.text)
                    elif fpkg_elem.get("type") == "ghost":
                        pp.ghosts.add(fpkg_elem.text)
                    else:
                        pp.files.add(fpkg_elem.text)
    return pp


def parse_filelists_pkg_elem(element):
    fp = FilelistsPackage()
    fp.checksum = element.get("pkgid")
    fp.arch = element.get("arch")
    fp.name = element.get("name")
    for pkg_elem in element:
        if pkg_elem.tag.endswith("version"):
            fp.epoch = pkg_elem.get("epoch")
            fp.version = pkg_elem.get("ver")
            fp.release = pkg_elem.get("rel")
        elif pkg_elem.tag.endswith("file"):
            if pkg_elem.get("type") == "dir":
                fp.dirs.add(pkg_elem.text)
            elif pkg_elem.get("type") == "ghost":
                fp.ghosts.add(pkg_elem.text)
            else:
                fp.files.add(pkg_elem.text)
    return fp


def parse_other_pkg_elem(element):
    op = OtherPackage()
    op.checksum = element.get("pkgid")
    op.arch = element.get("arch")
    op.name = element.get("name")
    for pkg_elem in element:
        if pkg_elem.tag.endswith("version"):
            op.epoch = pkg_elem.get("epoch")
            op.version = pkg_elem.get("ver")
            op.release = pkg_elem.get("rel")
        elif pkg_elem.tag.endswith("changelog"):
            op.changelogs.append((pkg_elem.get("author"), int(pkg_elem.get("date")), pkg_elem.text))
    return op


def parse_repomd_item_elem(element):
    re = RepomdItem()
    re.name = element.get("type")
    for item_elem in element:
        if item_elem.tag.endswith("location"):
            re.location_href = item_elem.get("href")
        elif item_elem.tag.endswith("open-size"):
            re.open_size = item_elem.text
        elif item_elem.tag.endswith("open-checksum"):
            re.open_checksum_type = item_elem.get("type")
            re.open_checksum = item_elem.text
        elif item_elem.tag.endswith("header-checksum"):
            pass
        elif item_elem.tag.endswith("header-size"):
            pass
        elif item_elem.tag.endswith("checksum"):
            re.checksum_type = item_elem.get("type")
            re.checksum = item_elem.text
        elif item_elem.tag.endswith("timestamp"):
            re.timestamp = item_elem.text
        elif item_elem.tag.endswith("size"):
            re.size = item_elem.text
        elif item_elem.tag.endswith("database_version"):
            re.database_version = item_elem.text
    return re
