import behave

from common import *

@behave.then("History is following")
def step_impl(context):
    def history_equal(history, table):
        if table['Id'] and table['Id'] != history['id']:
            return False
        if table['Action'] and table['Action'] != history['action']:
            return False
        if table['Altered'] and table['Altered'] != history['altered']:
            return False
        if table['Command']:
            # command column in `history list` output is trimmed to limited space
            # to get full command, we need to ask `history info`
            cmd = " ".join(context.dnf.get_cmd(context) + ["history", "info", history['id']])
            _, cmd_stdout, _ = run(cmd, shell=True, can_fail=False)
            h_info = parse_history_info(cmd_stdout.splitlines())
            if not table['Command'] in h_info.get('Command Line', ''):
                return False
        return True

    check_context_table(context, ["Id", "Command", "Action", "Altered"])

    cmd = " ".join(context.dnf.get_cmd(context) + ["history", "list"])
    _, cmd_stdout, _ = run(cmd, shell=True, can_fail=False)

    stdout_lines = cmd_stdout.splitlines()[2:]
    history = parse_history_list(stdout_lines)

    table_idx = 0
    for t_line in context.table:
        try:
            h_line = history[table_idx]
        except IndexError:
            print(cmd_stdout)
            raise AssertionError(
                "[history] table line (%s, %s, %s, %s) missing in history" % (
                    t_line['Id'], t_line['Command'], t_line['Action'], t_line['Altered']))
        if not history_equal(h_line, t_line):
            print(cmd_stdout)
            raise AssertionError(
                "[history] table line (%s, %s, %s, %s) does not match \"%s\"" % (
                    t_line['Id'], t_line['Command'], t_line['Action'], t_line['Altered'],
                    h_line['_line']))
        table_idx += 1

    if len(history) > table_idx:
        print(cmd_stdout)
        raise AssertionError(
            "[history] Following history lines not captured in the table:\n%s" % (
                '\n'.join(stdout_lines[table_idx:])))
