import re

import rpm


NEVRA_RE = re.compile(r"^(.+)-([0-9]+):(.+)-(.+)\.(.+)$")
INSTALLONLY_PROVIDES = {b'kernel', b'kernel-PAE', b'installonlypkg(kernel)',
                        b'installonlypkg(kernel-module)', b'installonlypkg(vm)',
                        b'multiversion(kernel)'}


class RPM(object):
    @staticmethod
    def parse(nevra):
        match = NEVRA_RE.match(nevra)
        if not match:
            raise ValueError("Cannot parse NEVRA: %s" % nevra)
        result = list(match.groups())
        result[1] = int(result[1])
        return result

    def __init__(self, nevra, rpmheader=None):
        nevra_split = self.parse(nevra)
        self.name = nevra_split[0]
        self.epoch = nevra_split[1]
        self.version = nevra_split[2]
        self.release = nevra_split[3]
        self.arch = nevra_split[4]
        self.rpmheader = rpmheader

    def __str__(self):
        return "%s-%d:%s-%s.%s" % (self.name, self.epoch, self.version, self.release, self.arch)

    def __repr__(self):
        return "<%s: %s>" % (self.__class__.__name__, self)

    def __hash__(self):
        return hash(str(self))

    def __eq__(self, other):
        if self.name != other.name:
            return False
        if self.epoch != other.epoch:
            return False
        if self.version != other.version:
            return False
        if self.release != other.release:
            return False
        if self.arch != other.arch:
            return False
        return True

    def __lt__(self, other):
        one = (str(self.epoch), self.version, self.release)
        two = (str(other.epoch), other.version, other.release)
        return rpm.labelCompare(one, two) <= -1

    def is_installonly(self):
        if not self.rpmheader:
            raise ValueError("rpm header not available: %s" % str(self))
        if INSTALLONLY_PROVIDES.intersection(self.rpmheader.provides):
            return True
        return False

def normalize_epoch(evr):
    if ":" not in evr:
        # prepend "0:" if there's no epoch specified
        return "0:" + evr
    return evr

def diff_rpm_lists(list_one, list_two):
    result = {
        # actions
        "install": set(),
        "remove": set(),
        "upgrade": set(),
        "upgraded": set(),
        "downgrade": set(),
        "downgraded": set(),
        "broken": set(),

        # it is not clear whether a RPM was reinstalled or not changed at all
        # use "unchanged" instead
        # "reinstalled": set(),

        "changed": set(),
        "unchanged": set(),
        "present": set(),
        "absent": set(),
    }

    dict_one = {str(i) if i.is_installonly() else i.name: i for i in list_one}
    dict_two = {str(i) if i.is_installonly() else i.name: i for i in list_two}

    names_one = set(dict_one.keys())
    names_two = set(dict_two.keys())

    for name in names_two - names_one:
        result["install"].add(dict_two[name])

    for name in names_one - names_two:
        result["remove"].add(dict_one[name])
        result["absent"].add(dict_one[name])

    for name in names_one & names_two:
        rpm_one = dict_one[name]
        rpm_two = dict_two[name]
        if rpm_one < rpm_two:
            result["upgraded"].add(rpm_one)
            result["upgrade"].add(rpm_two)
        elif rpm_one > rpm_two:
            result["downgraded"].add(rpm_one)
            result["downgrade"].add(rpm_two)
        else:
            result["unchanged"].add(rpm_two)

    result["present"] = set(list_two)
    result["changed"] = result["present"] - result["unchanged"]

    return result
