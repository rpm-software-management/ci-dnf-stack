# -*- coding: utf-8 -*-

import sqlite3
import os

from lib.repodata_representation import Metadata
from lib.repodata_representation import PrimaryPackage
from lib.repodata_representation import FilelistsDbPackage
from lib.repodata_representation import OtherPackage


# This maps names between xml a sqlite repodata representations
COL_PACKAGES_MAPPING = {"checksum": "pkgId",
                        "name": "name",
                        "arch": "arch",
                        "version": "version",
                        "epoch": "epoch",
                        "release": "release",
                        "summary": "summary",
                        "description": "description",
                        "url": "url",
                        "time_file": "time_file",
                        "time_build": "time_build",
                        "license": "rpm_license",
                        "vendor": "rpm_vendor",
                        "group": "rpm_group",
                        "buildhost": "rpm_buildhost",
                        "sourcerpm": "rpm_sourcerpm",
                        "header_start": "rpm_header_start",
                        "header_end": "rpm_header_end",
                        "packager": "rpm_packager",
                        "size_package": "size_package",
                        "size_installed": "size_installed",
                        "size_archive": "size_archive",
                        "location": "location_href",
                        "location_base": "location_base",
                        "checksum_type": "checksum_type"}


def load_sqlite(sqlite_path, repodata_type):
    metadata_obj = Metadata(sqlite_path)
    con = sqlite3.Connection(sqlite_path)
    con.row_factory = sqlite3.Row

    if repodata_type == "primary":
        parse_pkg = parse_primary_pkg_sqlite
    elif repodata_type == "filelists":
        parse_pkg = parse_filelists_pkg_sqlite
    elif repodata_type == "other":
        parse_pkg = parse_other_pkg_sqlite

    for row in con.execute("SELECT * FROM packages"):
        p = parse_pkg(row, con)
        metadata_obj.append(p.checksum, p)
    return metadata_obj


def parse_primary_pkg_sqlite(row, con):
    pp = PrimaryPackage()
    uid = row["pkgKey"]
    for map_to, map_from in COL_PACKAGES_MAPPING.items():
        setattr(pp, map_to, row[map_from])
    if pp.location_base is None:
        pp.location_base = ''

    # provides, conflicts, obsoletes
    for pco in ("provides", "conflicts", "obsoletes"):
        pco_set = set()
        for name, flag, epoch, ver, rel, _ in con.execute("SELECT * FROM %s WHERE pkgKey=?" % pco, (uid,)):
            pco_set.add((name, flag, epoch, ver, rel))
        setattr(pp, pco, pco_set)

    # requires
    req_set = set()
    for name, flag, epoch, ver, rel, _, pre in con.execute('SELECT * FROM requires WHERE pkgKey=?', (uid,)):
        req_set.add((name, flag, epoch, ver, rel, pre == 'TRUE'))
    setattr(pp, 'requires', req_set)

    # files
    for filename, ftype in con.execute('SELECT name, type FROM files WHERE pkgKey=?', (uid,)):
        if ftype == 'file':
            pp.files.add(filename)
        elif ftype == 'dir':
            pp.dirs.add(filename)
        elif ftype == 'ghost':
            pp.ghosts.add(filename)
    return pp


def parse_filelists_pkg_sqlite(row, con):
    fp = FilelistsDbPackage()
    pkgkey = row["pkgKey"]
    fp.checksum = row["pkgId"]
    cur = con.cursor()
    cur.execute("SELECT dirname, filenames, filetypes FROM filelist WHERE pkgKey=?", (pkgkey,))

    for dirname, filenames, filetypes in cur:
        # filenames is a string in format: names separated by '/': "file1/file2/forder3", however '/' is also
        # a name of root directory -> if it is present we want to remove it before splitting
        # so that we get empty string in the place of the root "/"
        if (filenames.startswith("//") and not filenames.startswith("///")):
            filenames = filenames[1:] # if the filenames string begins with root dir ("/")
        if (filenames.endswith("//") and not filenames.endswith("///")):
            filenames = filenames[:-1] # if the filenames string ends with root dir ("/")
        filenames = filenames.replace("///", "//") # if root dir ("/") is in the middle of two other names

        splited_filenames = filenames.split('/')
        for filename, ftype in zip(splited_filenames, list(filetypes)):
            # If in XML is "foo" in db will be DIR: "." FILE: "foo"
            # Thus result will be "./foo" after join, so if dir is "."
            # do not do a join
            if dirname != ".":
                path = os.path.join(dirname, filename)
            else:
                path = filename

            if ftype == 'f':
                fp.files.add(path)
                fp.files_db.add(filename)
            elif ftype == 'd':
                fp.dirs.add(path)
                fp.dirs_db.add(filename)
            else:
                fp.ghosts.add(path)
                fp.ghosts_db.add(filename)
            fp.dbdirectories.append(dirname)
    fp.dbdirectories = sorted(fp.dbdirectories)
    return fp


def parse_other_pkg_sqlite(row, con):
    op = OtherPackage()
    pkgkey = row["pkgKey"]
    op.checksum = row["pkgId"]

    cur = con.cursor()
    cur.execute('SELECT author, date, changelog FROM changelog WHERE pkgKey=? ORDER BY date ASC', (pkgkey,))
    for author, date, changelog in cur:
        op.changelogs.append((author, date, changelog))

    return op
