from behave import given
from behave import when
from behave import then
import pexpect
import sys


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
    context.cmd_result = None
    context.assertion.assertNotEqual(None, context.pexpect_session, "dnf shell session must be opened first")
    context.pexpect_session.sendline(command)
    if command.strip() == 'quit' or command.strip() == 'exit':
        context.pexpect_session.expect(pexpect.EOF)
        context.cmd_result = context.pexpect_session.before
        sys.stdout.write(context.pexpect_session.before)
        context.pexpect_session = None
    else:
        context.pexpect_session.expect('\r\n[^ \r-]*> ')
        context.cmd_result = context.pexpect_session.before[len(command):]
        sys.stdout.write("{}{}".format(context.pexpect_session.before, context.pexpect_session.match.group()))


@then('the command output should contain "{text}"')
def step_the_command_output_shoud_contain(context, text):
    assert text in context.cmd_result


@then('the command output should not contain "{text}"')
def step_the_command_output_shoud_not_contain(context, text):
    assert text not in context.cmd_result
