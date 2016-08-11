from __future__ import absolute_import
from __future__ import unicode_literals

import sys

from behave import register_type
from behave import then
from behave import when
import parse

import command_utils

@parse.with_pattern(r"stdout|stderr")
def parse_stdout_stderr(text):
    return text

register_type(stdout_stderr=parse_stdout_stderr)

@when('I run "{command}"')
def step_i_run_command(ctx, command):
    """
    Run a ``{command}`` as subprocess, collect its output and returncode.
    """
    ctx.cmd_result = command_utils.run(ctx, command)

@when('I successfully run "{command}"')
def step_i_successfully_run_command(ctx, command):
    step_i_run_command(ctx, command)
    step_the_command_should_pass(ctx)

@then("the command should pass")
def step_the_command_should_pass(ctx):
    ctx.assertion.assertEqual(ctx.cmd_result.returncode, 0)

@then("the command should fail")
def step_the_command_should_fail(ctx):
    ctx.assertion.assertNotEqual(ctx.cmd_result.returncode, 0)

@then("the command {stream:stdout_stderr} should contain exactly")
def step_the_command_stream_should_contain_exactly(ctx, stream):
    ctx.assertion.assertIsNotNone(ctx.text, "Multiline text is not provided")
    text = getattr(ctx.cmd_result, stream)
    ctx.assertion.assertMultiLineEqual(text, ctx.text)

@then("the command {stream:stdout_stderr} should be empty")
def step_the_command_stream_should_be_empty(ctx, stream):
    ctx.text = ""
    step_the_command_stream_should_contain_exactly(ctx, stream)
