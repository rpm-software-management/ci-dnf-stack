# -*- coding: utf-8 -*-

from lib.repodata import build_nevra

class MetadataItem(object):
    diff_attr = tuple()
    non_and_empty_are_same = tuple()

    def diff(self, other):
        comparable_attributes = set(self.diff_attr).intersection(set(other.diff_attr))
        for key in comparable_attributes:
            a = getattr(self, key)
            b = getattr(other, key)

            if key in self.non_and_empty_are_same:
                if not a and not b:
                    continue

            if key == "location_base" or key == "location_href":
                if a.startswith("file://"):
                    a = a[7:]
                if b.startswith("file://"):
                    b = b[7:]

            if a != b:
                return "Attribute \"%s\" is different:\n" \
                       "\"%s\" != \"%s\"\n" % (key, a, b)
        return None


class Metadata(object):
    def __init__(self, location):
        self.items = {}
        self.path = location

    def append(self, key, item):
        if key in self.items:
            print("WARNING: Multiple items with the same key \"%s\":\n"
                  "   1: %s\n  2: %s\n" % (key, self.items[key], item))
            return
        self.items[key] = item

    def diff(self, other):
        checksums_a = set(self.items.keys())
        checksums_b = set(other.items.keys())
        if checksums_a != checksums_b:
            return "Different package sets"
        for checksum in checksums_a:
            pkg_a = self.items[checksum]
            pkg_b = other.items[checksum]
            pkg_diff = pkg_a.diff(pkg_b)
            if pkg_diff:
                return "Package %s:\n" \
                       "Difference: %s" % (pkg_a.nevra(), pkg_diff)
        return None

    def keys(self):
        return self.items.keys()

    def packages(self):
        return [pkg.nevra() for (k, pkg) in self.items.items()]


class Package(MetadataItem):
    diff_attr = ("checksum")
    non_and_empty_are_same = ("location_base",
                              "vendor",
                              "description",
                              "sourcerpm")

    def __init__(self):
        super(Package, self).__init__()
        self.checksum = "" # pkgid
        self.epoch = ""
        self.name = ""
        self.version = ""
        self.release = ""
        self.arch = ""

    def nevra(self):
        return build_nevra(self.name, self.epoch, self.version, self.release, self.arch)


class PrimaryPackage(Package):
    diff_attr = None

    def __init__(self):
        super(PrimaryPackage, self).__init__()
        self.pkgkey = ""
        self.summary = ""
        self.description = ""
        self.url = ""
        self.time_file = ""
        self.time_build = ""
        self.license = ""
        self.vendor = ""
        self.group = ""
        self.buildhost = ""
        self.sourcerpm = ""
        self.header_start = ""
        self.header_end = ""
        self.packager = ""
        self.size_package = ""
        self.size_installed = ""
        self.size_archive = ""
        self.location = ""
        self.location_base = ""
        self.checksum_type = ""
        self.provides = set()  # set([('fn', flags, epoch, ver, rel), ...])
        self.conflicts = set()  # -||-
        self.obsoletes = set()  # -||-
        self.requires = set() # set([(fn, flags, epoch, ver, rel, pre), ...])
        # ^^^ It's because there can be multiple files with the
        #     same name, but different attributes
        self.files = set()  # primary_files
        self.dirs = set()  # primary_dirs
        self.ghosts = set()  # primary_ghosts

        # Let's diff all of out attributes
        if not self.diff_attr:
            self.diff_attr = self.__dict__.keys()


class FilelistsPackage(Package):
    diff_attr = ("checksum", "files", "dirs", "ghosts")

    def __init__(self):
        Package.__init__(self)
        self.files = set()
        self.dirs = set()
        self.ghosts = set()


class FilelistsDbPackage(FilelistsPackage):
    diff_attr = ("checksum", "files", "dirs", "ghosts",
                 "dbdirectories", "files_db", "dirs_db", "ghosts_db")

    def __init__(self):
        FilelistsPackage.__init__(self)
        self.dbdirectories = list()
        self.files_db = set()
        self.dirs_db = set()
        self.ghosts_db = set()


class OtherPackage(Package):
    diff_attr = ('checksum', 'changelogs')

    def __init__(self):
        Package.__init__(self)
        self.changelogs = [] # [(author, date, text), ...]


class RepomdItem(MetadataItem):
    def __init__(self):
        MetadataItem.__init__(self)
        self.name = ""
        self.checksum = ""
        self.location_href = ""
        self.checksum_type = ""
        self.timestamp = ""
        self.size = ""
        self.open_size = ""
        self.open_checksum = ""
        self.open_checksum_type = ""
        self.database_version = ""
