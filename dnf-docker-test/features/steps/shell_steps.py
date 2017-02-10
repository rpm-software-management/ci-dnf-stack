from behave import given
from behave import when
import pexpect
import sys
from command_utils import CommandResult

@given('I have dnf shell session opened with parameters "{parameters}"')
def step_i_have_dnf_shell_session_opened_with_parameters(context, parameters):
    dnf_command_version = context.command_map["dnf"]
    sys.stdout.write('# {} shell {}\n'.format(dnf_command_version, parameters))
    context.pexpect_session = pexpect.spawn('{} shell {}'.format(dnf_command_version, parameters))
    context.pexpect_session.expect('> ')
    sys.stdout.write("{}{}".format(context.pexpect_session.before, context.pexpect_session.match.group()))
    context.cmd_result = None

@when('I run dnf shell command "{command}"')
def step_i_run_dnf_shell_command(context, command):
    context.cmd_result = CommandResult()
    context.assertion.assertNotEqual(None, context.pexpect_session, "dnf shell session must be opened first")
    context.pexpect_session.sendline(command)
    if command.strip() == 'quit' or command.strip() == 'exit':
        context.pexpect_session.expect(pexpect.EOF)
        # in the dnf shell command output we need to replace ^M characters added by pexpect
        context.cmd_result.stdout = context.pexpect_session.before[len(command) + 2:].replace('\r\n', '\n')
        sys.stdout.write(context.pexpect_session.before)
        context.pexpect_session = None
    else:
        idx = context.pexpect_session.expect(['\r\n[^ \r-]*> ', pexpect.EOF])
        # in the dnf shell command output we need to replace ^M characters added by pexpect
        context.cmd_result.stdout = context.pexpect_session.before[len(command) + 2:].replace('\r\n', '\n')
        sys.stdout.write(context.pexpect_session.before)
        if idx == 0:
            sys.stdout.write(context.pexpect_session.match.group())
