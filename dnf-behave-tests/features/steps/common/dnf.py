import re


from .rpm import normalize_epoch
from .rpm import RPM


SEPARATOR_RE = re.compile(r"^[> ]*=+$")
ACTION_RE = re.compile(r"^([^ ].+):$")
DESCRIPTION_RE = re.compile(r"^\(.*\):$")
PACKAGE_RE = re.compile(r" (?P<name>[^ ]+) *(?P<arch>[^ ]+) *(?P<evr>[^ ]+) *(?P<repo>[^ ]+) *(?P<size>.+)$")
MODULE_LIST_HEADER_RE = re.compile(r"^(Name)\s+(Stream)\s+(Profiles)\s+(Summary)\s*$")
MODULE_STREAM_RE = re.compile(r"(?P<module>[^ ]+) *(?P<stream>[^ ]+)$")

OBSOLETE_REPLACING_LABEL = {
    'en_US': 'replacing',
    'cs_CZ': 'nahrazování',
}
OBSOLETE_REPLACING = re.compile(
    r"^ +(?P<label>%s) +(?P<name>[^ ]*)\.(?P<arch>[^ ]+) +(?P<evr>.*)$" \
        % '|'.join(OBSOLETE_REPLACING_LABEL.values()))


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
    "Installing group/module packages": "install",
    "Installing Groups": "group-install",
    "Removing Groups": "group-remove",
    "Upgrading Groups": "group-upgrade",
    "Installing module profiles": "module-profile-install",
    "Removing module profiles": "module-profile-remove",
    "Enabling module streams": "module-stream-enable",
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
        line4 = lines[i + 3]
        i += 1

        match = SEPARATOR_RE.match(line1)
        if not match:
            continue

        match = PACKAGE_RE.match(line2)
        if not match:
            continue

        match = SEPARATOR_RE.match(line3)
        if not match:
            # sometimes line2 ("Package  Arch  Ver..") can be split to two lines
            # which moves line3 to line4
            match = SEPARATOR_RE.match(line4)
            if not match:
                continue
            else:
                return i + 3

        return i + 2

    raise RuntimeError("Transaction table start not found")


def find_transaction_table_end(lines):
    """
    Find a DNF transaction table end:
    Transaction Summary
    ===================
    """
    for i, line in enumerate(lines):
        match = SEPARATOR_RE.match(line)
        if match:
            return i - 1
    raise RuntimeError("Transaction table end not found")


def parse_transaction_table(lines):
    """
    Find and parse transaction table.
    Return {action: set([rpms])}
    """
    result = {}
    for action in ACTIONS.values():
        result[action] = set()

    table_begin = find_transaction_table_begin(lines)
    lines = lines[table_begin:]

    table_end = find_transaction_table_end(lines)
    lines = lines[:table_end]

    # lines in transaction table could be splitted, join them
    # also remove empty lines
    if lines:
        joined_lines = [lines[0]]
        for line in lines[1:]:
            if OBSOLETE_REPLACING.match(line):
                joined_lines.append(line)
            elif line.startswith('  '):
                joined_lines[-1] = joined_lines[-1] + line
            elif line.rstrip() == "":
                continue
            else:
                joined_lines.append(line)
        lines = joined_lines

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

            if action.startswith('group-') or action.startswith('module-'):
                if ACTION_RE.match(line):
                    break
                lines.pop(0)
                if '-stream-' in action:
                    match = MODULE_STREAM_RE.match(line.strip())
                    if not match:
                        raise ValueError("Couldn't parse module/stream: {}".format(line))
                    result[action].add("{0[module]}:{0[stream]}".format(match.groupdict()))
                else:
                    group = line.strip()
                    result[action].add(group)
                continue

            result_action = action
            # catch obsoletes lines in form "     replacing name.arch evr"
            match = OBSOLETE_REPLACING.match(line)
            if match:
                result_action = 'remove'
            else:
                # XXX ugly hack
                # bug in dnf output: sometimes there is no space
                # between arch and version and matching fails,
                # but I'm not able to reproduce this behavior outside of behave.
                # module-install.feature
                #line = re.sub(r'(x86_64|noarch)(?! )', r'\1 ', line)
                match = PACKAGE_RE.match(line)
            if not match:
                # either next action or parsing error
                break

            lines.pop(0)
            match_dict = match.groupdict()
            match_dict["evr"] = normalize_epoch(match_dict["evr"])
            nevra = "{0[name]}-{0[evr]}.{0[arch]}".format(match_dict)
            rpm = RPM(nevra)
            result[result_action].add(rpm)

    return result


def parse_history_list(lines):
    result = []
    labels = ('_line', 'id', 'command', 'date', 'action', 'altered')
    for line in lines:
        result.append(dict(zip(labels, [line] + [col.strip() for col in line.split('|')])))
    return result


def parse_history_info(lines):
    result = dict()
    result[None] = []
    for line in lines:
        if ':' in line:
            key, val = [s.strip() for s in line.split(':', 1)]
            result[key] = val
        else:
            result[None].append(line.strip())
    return result


def parse_module_list(lines):
    """
    Parse `module list` command output.
    Returns {repository: [{'name': module_name, 'stream': module_stream,
                           'profiles': set([module profiles])}]}
    """
    def get_column(idx, columns, line):
        if idx < (len(columns) - 1):
            return line[columns[idx]:columns[idx+1]].strip()
        else:
            return line[columns[idx:]].strip()

    result = dict()
    idx = 0
    repository = None
    while idx < len(lines) - 2:
        line1 = lines[idx].strip()
        line2 = lines[idx + 1].strip()
        if not line1:
            # empty line separates the repositories
            repository = None
        match = MODULE_LIST_HEADER_RE.match(line2)
        if match:
            # table header for a new repository found
            repository = line1
            columns=[match.start(i+1) for i in range(4)]
            result[repository] = []
            idx += 2
            continue
        if repository:
            # record module line for repository
            module = dict()
            module['repository'] = repository
            module['name'] = get_column(0, columns, line1)
            module['stream'] = get_column(1, columns, line1)
            module['profiles'] = set(
                [p.strip()
                 for p in get_column(2, columns, line1).split(',')])
            result[repository].append(module)
        idx += 1
    return result
