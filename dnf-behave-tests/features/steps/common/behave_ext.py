from .dnf import ACTIONS
from .rpm import RPM
from .string import splitter

def check_context_table(context, headings):
    if not context.table:
        raise ValueError("Table not specified.")

    if context.table.headings != headings:
        raise ValueError("Invalid table headings. Expected: %s" % ", ".join(headings))

def parse_context_table(context):
    result = {}
    for action in ACTIONS.values():
        result[action] = set()

    for action, nevras in context.table:
        if action not in result:
            continue
        if action.startswith('group-') or action.startswith('module-'):
            for group in splitter(nevras):
                result[action].add(group)
        else:
            for nevra in splitter(nevras):
                rpm = RPM(nevra)
                result[action].add(rpm)

    return result
