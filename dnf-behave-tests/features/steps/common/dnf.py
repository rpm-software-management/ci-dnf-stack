import re


from .rpm import RPM


SEPARATOR_RE = re.compile(r"^=+$")
ACTION_RE = re.compile(r"^([^ ].+):$")
DESCRIPTION_RE = re.compile(r"^\(.*\):$")
PACKAGE_RE = re.compile(r" (?P<name>[^ ]+) *(?P<arch>[^ ]+) *(?P<evr>[^ ]+) *(?P<repo>[^ ]+) *(?P<size>.+)$")


ACTIONS_EN = {
    "Installing": "install",
    "Upgrading": "upgrade",
    "Reinstalling": "reinstall",
    "Installing dependencies": "install",
    "Installing weak dependencies": "install",
    "Removing": "remove",
    "Removing dependent packages": "remove",
    "Removing unused dependencies": "remove",
    "Downgrading": "downgrade",
    "Skipping packages with broken dependencies": "broken",
}


ACTIONS = {}
ACTIONS.update(ACTIONS_EN)


def find_transaction_table_begin(lines):
    """
    Find a DNF transaction table header and return index of a following line:
    ==========================================
     Package  Arch  Version  Repository  Size
    ==========================================
    """

    i = 0
    while i < len(lines) - 3:
        line1 = lines[i]
        line2 = lines[i + 1]
        line3 = lines[i + 2]
        i += 1

        match = SEPARATOR_RE.match(line1)
        if not match:
            continue

        match = PACKAGE_RE.match(line2)
        if not match:
            continue

        match = SEPARATOR_RE.match(line3)
        if not match:
            continue

        return i + 2

    raise RuntimeError("Transaction table start not found")


def find_transaction_table_end(lines):
    """
    Find a DNF transaction table end: an empty line
    """
    for i, line in enumerate(lines):
        line = line.rstrip()
        if not line:
            return i
    raise RuntimeError("Transaction table end not found")


def parse_transaction_table(lines):
    """
    Find and parse transaction table.
    Return {action: set([rpms])}
    """
    result = {}

    table_begin = find_transaction_table_begin(lines)
    lines = lines[table_begin:]

    table_end = find_transaction_table_end(lines)
    lines = lines[:table_end]

    while lines:
        line = lines.pop(0).rstrip()

        # skip descriptions such as: (add '--best --allowerasing' to command line to force their upgrade):
        match = DESCRIPTION_RE.match(line)
        if match:
            continue

        match = ACTION_RE.match(line)
        if not match:
            raise RuntimeError("Couldn't parse transaction table action: {}".format(line))
        line_action = match.group(1)
        action = ACTIONS[line_action]

        while True:
            if not lines:
                break

            line = lines[0].rstrip()
            match = PACKAGE_RE.match(line)

            if not match:
                # either next action or parsing error
                break

            lines.pop(0)
            match_dict = match.groupdict()
            if ":" not in match_dict["evr"]:
                # prepend "0:" if there's no epoch specified
                match_dict["evr"] = "0:" + match_dict["evr"]
            nevra = "{0[name]}-{0[evr]}.{0[arch]}".format(match_dict)
            rpm = RPM(nevra)
            result.setdefault(action, set()).add(rpm)

    return result
