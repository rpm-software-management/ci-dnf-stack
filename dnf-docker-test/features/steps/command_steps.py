from __future__ import absolute_import
from __future__ import unicode_literals

from behave import register_type
from behave import then
from behave import step
import parse
import re

import command_utils
import repo_utils
import table_utils

@parse.with_pattern(r"stdout|stderr")
def parse_stdout_stderr(text):
    return text

register_type(stdout_stderr=parse_stdout_stderr)

@step('I run "{command}"')
def step_i_run_command(ctx, command):
    """
    Run a ``{command}`` as subprocess, collect its output and returncode.
    """
    ctx.cmd_result = command_utils.run(ctx, command)

@step('I successfully run "{command}" in repository "{repository}"')
def step_i_successfully_run_command_in_repository(ctx, command, repository):
    repo = repo_utils.get_repo_dir(repository)
    ctx.assertion.assertIsNotNone(repo, "repository does not exist")
    ctx.cmd_result = command_utils.run(ctx, command, cwd=repo)
    ctx.assertion.assertEqual(ctx.cmd_result.returncode, 0)

@step('I successfully run "{command}"')
def step_i_successfully_run_command(ctx, command):
    step_i_run_command(ctx, command)
    step_the_command_should_pass(ctx)

@then("the command should pass")
def step_the_command_should_pass(ctx):
    ctx.assertion.assertEqual(ctx.cmd_result.returncode, 0)

@then("the command should fail")
def step_the_command_should_fail(ctx):
    ctx.assertion.assertNotEqual(ctx.cmd_result.returncode, 0)

@then("the command exit code is {values}")
def step_the_command_exit_code_is(ctx, values):
    """
    Compares the exit code of the previous command with a given value or comma separated list of values or ranges, e.g. '1,3,100-102'.
    """
    codes = []
    parts = values.split(',')
    for part in parts:
        if '-' in part:  # range a-b
            (lower, upper) = part.split('-', 1)
            lower = int(lower.strip())
            upper = int(upper.strip())
            codes.extend(range(lower, upper+1))
        else:
            codes.append(int(part.strip()))  # just plain number
    ctx.assertion.assertIn(ctx.cmd_result.returncode, codes)

@then("the command {stream:stdout_stderr} should match")
def step_the_command_stream_should_match(ctx, stream):
    """
    Match multiline output from ``{stream}`` with text on the following lines.\n
    Trailing spaces and newlines are ignored.

    Example:
        When I successfully run "dummy command"\n
        Then the command stdout should match
             \"\"\"\n
             Dummy output\n
             on\n
             multiple lines!\n
             \"\"\"
    """
    ctx.assertion.assertIsNotNone(ctx.text, "Multiline text is not provided")
    text = getattr(ctx.cmd_result, stream)
    textcore = ""
    for line in text.split('\n'):
        stripped = line.rstrip()
        if stripped:
            textcore += stripped + '\n'
    ctxcore = ""
    for line in ctx.text.split('\n'):
        stripped = line.rstrip()
        if stripped:
            ctxcore += stripped + '\n'
    ctx.assertion.assertMultiLineEqual(textcore, ctxcore)

@then("the command {stream:stdout_stderr} should match exactly")
def step_the_command_stream_should_match_exactly(ctx, stream):
    ctx.assertion.assertIsNotNone(ctx.text, "Multiline text is not provided")
    text = getattr(ctx.cmd_result, stream)
    ctx.assertion.assertMultiLineEqual(text, ctx.text)

@then("the command {stream:stdout_stderr} should be empty")
def step_the_command_stream_should_be_empty(ctx, stream):
    ctx.text = ""
    step_the_command_stream_should_match_exactly(ctx, stream)

@then('the command {stream:stdout_stderr} should match line by line regexp')
def step_the_command_stream_should_match_regexp_line_by_line(ctx, stream):
    """
    Match multiline output from ``{stream}`` against regular expressions
    provided on the following lines line by line.
    Regexp prefixed with ? is considered as optional match.

    Example:
        When I successfully run "dummy command"\n
        Then the command stdout should match line by line regexp
             \"\"\"\n
             ?optional_regexp_pattern\n
             regexp_for_1st_line\n
             regexp_for_2nd_line\n
             \"\"\"
    """
    ctx.assertion.assertIsNotNone(ctx.text, "Multiline text is not provided")
    regexp_list = ctx.text.split('\n')
    text = getattr(ctx.cmd_result, stream)  # read cmd output
    cmdout_list = text.split('\n')
    # following is a very ugly hack due to a dnf bug not wrapping lines properly
    # we will normalize the output, i.e. split lines longer then terminal width
    cmdout_list_norm = []
    prev_line_length = 80
    for line in cmdout_list:
        if len(line) <= 80:
            cmdout_list_norm.append(line)
            prev_line_length = len(line)
        else:  # table? need to split according to the length of the previous line (heading?)
            cmdout_list_norm.extend([line[i:i + prev_line_length] for i in range(0, len(line), prev_line_length)])
    cmdout_list = cmdout_list_norm
    # -- end of the hack
    while cmdout_list:
        line = cmdout_list.pop(0)
        if line and (not regexp_list):  # there is no remaining regexp
            raise AssertionError("Not having a regexp to match line '%s'" % line)
        elif regexp_list:
            regexp = regexp_list.pop(0)
            while regexp.startswith('?'):
                if not re.search(regexp[1:], line):  # optional regexp that doesn't need to be matched
                    if regexp_list:
                        regexp = regexp_list.pop(0)
                    else:
                        raise AssertionError("Not having a regexp to match line '%s'" % line)
                else:
                    regexp = regexp[1:]
            ctx.assertion.assertRegexpMatches(line, regexp)
    if regexp_list:  # there are some unprocessed regexps
        raise AssertionError("No more line to match regexp '%s'" % regexp_list[0])

@then('the command {stream:stdout_stderr} should match regexp "{regexp}"')
def step_the_command_stream_should_match_regexp(ctx, stream, regexp):
    text = getattr(ctx.cmd_result, stream)
    ctx.assertion.assertRegexpMatches(text, regexp)

@then('the command {stream:stdout_stderr} should not match regexp "{regexp}"')
def step_the_command_stream_should_not_match_regexp(ctx, stream, regexp):
    text = getattr(ctx.cmd_result, stream)
    ctx.assertion.assertNotRegexpMatches(text, regexp)

@then('the command {stream:stdout_stderr} section "{section}" should match exactly')
def step_the_command_stream_section_should_match_exactly(ctx, stream, section):
    """
    Compares the content of a particular section from the command output with a given multiline text

    Examples:

    .. code-block:: gherkin

      Feature: DNF output section content matching

        Scenario: Verify the transaction output"
          Given I use the repository "test-1"
           When I successfully run "dnf -y install TestA TestB"
           Then the command stdout section "Installing:" should match exactly
             \"\"\"
              TestA            noarch            1.0.0-1             test-1            5.7 k
              TestB            noarch            1.0.0-1             test-1            5.7 k
             \"\"\"
            And the command stdout section "Installed:" should match regexp "TestA\.noarch.*TestB\.noarch"
    """
    ctx.assertion.assertIsNotNone(ctx.text, "Multiline text is not provided")
    text = getattr(ctx.cmd_result, stream)
    section_content = command_utils.extract_section_content_from_text(section, text)
    ctx.assertion.assertRegexpMatches(section_content, ctx.text)

@then('the command {stream:stdout_stderr} section "{section}" should match regexp "{regexp}"')
def step_the_command_stream_section_should_match_regexp(ctx, stream, section, regexp):
    """Compares the content of a particular section from the command output with a given regexp"""
    text = getattr(ctx.cmd_result, stream)
    section_content = command_utils.extract_section_content_from_text(section, text)
    ctx.assertion.assertRegexpMatches(section_content, regexp)

@then('the command {stream:stdout_stderr} section "{section}" should not match regexp "{regexp}"')
def step_the_command_stream_section_should_not_match_regexp(ctx, stream, section, regexp):
    """Compares the content of a particular section from the command output with a given regexp"""
    text = getattr(ctx.cmd_result, stream)
    section_content = command_utils.extract_section_content_from_text(section, text)
    ctx.assertion.assertNotRegexpMatches(section_content, regexp)

@then('history should match "{cmd}" with "{act}" and "{alt}" package')
@then('history should match "{cmd}" with "{act}" and "{alt}" packages')
@then('history "{range}" should match "{cmd}" with "{act}" and "{alt}" package')
@then('history "{range}" should match "{cmd}" with "{act}" and "{alt}" packages')
def step_history_contains(ctx, cmd, act, alt, range=""):
    step_i_run_command(ctx, 'dnf history ' + range)
    text = getattr(ctx.cmd_result, 'stdout')
    lines = text.split('\n')
    assert len(lines) > 2, 'No output'
    del lines[:2]
    match = False
    for line in lines:
        columns = line.split('|')
        words = [word.strip() for word in columns]
        # last member can be e.g. "1 >"
        words += words[-1].split()
        if set([cmd, act, alt]).issubset(set(words)):
            match = True
            break
    assert match, '"{}" with "{}" and "{}" packages not matched!'.format(cmd, act, alt)

@then('history userinstalled should')
def step_userinstalled_match(ctx):
    def pkgs_split(pkgs):
        for pkg in pkgs.split(","):
            yield pkg.strip()
    keys = ['Match', 'Not match']
    table = table_utils.parse_kv_table(ctx, ['Action', 'Packages'], keys)
    step_i_run_command(ctx, 'dnf history userinstalled')
    text = getattr(ctx.cmd_result, 'stdout')

    match = table[keys[0]] if keys[0] in table else None
    notmatch = table[keys[1]] if keys[1] in table else None

    if match:
        for m in pkgs_split(match):  # should be matched
            assert m in text, 'Package {} not matched as userinstalled'.format(m)
    if notmatch:
        for n in pkgs_split(notmatch):  # should not be matched
            assert n not in text, 'Package {} matched as userinstalled'.format(m)

@then('history info "{spec}" should match')
@then('history info should match')
def step_history_info(ctx, spec=""):
    def pkgs_split(pkgs):
        return pkgs.split(",")

    actions = ['Install', 'Erase', 'Upgrade', 'Upgraded', 'Reinstall', 'Downgrade']
    keys = ['Command Line', 'Return-Code'] + actions

    table = table_utils.parse_kv_table(ctx, ['Key', 'Value'], keys)
    step_i_run_command(ctx, 'dnf history info ' + spec)

    text = getattr(ctx.cmd_result, 'stdout')
    lines = text.split('\n')
    assert text and lines, 'No output'

    brpmdb = None
    erpmdb = None
    cmdline = None
    g_cmdline = table['Command Line'] if 'Command Line' in table else None
    retcode = None
    g_retcode = table['Return-Code'] if 'Return-Code' in table else None

    for line in lines:
        if 'Begin rpmdb' in line:
            brpmdb = line.split(':')

        if 'End rpmdb' in line:
            erpmdb = line.split(':')

        if brpmdb and erpmdb:
            assert len(brpmdb) == len(erpmdb) == 3, 'Unexpected rpmdb version format'
            erpmdb = None

        if 'Return-Code' in line and g_retcode:
            retcode = line.split(':')
            assert len(retcode) == 2, 'Unexpected Return-Code format'
            rc = retcode[1].strip()
            assert rc == g_retcode, 'Return-Code "{}" not matched by "{}"'.format(rc, g_retcode)

        if 'Command Line' in line and g_cmdline:
            cmdline = line.split(':')
            assert len(cmdline) == 2, 'Unexpected Command Line format'
            cmd = cmdline[1].strip()
            assert cmd == g_cmdline, 'Command Line "{}" not matched by "{}"'.format(cmd, g_cmdline)

    assert brpmdb, 'Begin rpmdb version not found'

    if g_cmdline:
        assert cmdline, 'Command line not found'

    if g_retcode:
        assert retcode, 'Return-Code not found'

    for key in actions:
        if key in table:
            pkgs = pkgs_split(table[key])
            for line in lines:
                for pkg in pkgs:
                    if pkg in line and key in line:
                        pkgs.remove(pkg)
            assert not pkgs, '"{}" not matched as "{}"'.format(pkgs[0], key)
