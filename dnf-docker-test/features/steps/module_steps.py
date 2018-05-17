from __future__ import absolute_import
from __future__ import unicode_literals

from behave import use_step_matcher, then

from file_steps import HEADINGS_INI
from file_steps import step_an_ini_file_filepath_should_contain
import table_utils

use_step_matcher("re")
@then('a module (?P<modulename>"?\w+"?) config file should contain')
def step_a_module_modulename_should_contain(ctx, modulename):
    """
    Tests whether a module config file contain respective Key, Value
    touples.

    ===== =======
     Key   Value
    ===== =======

    Examples:

    .. code-block:: gherkin

       Feature: Testing a module config file content
         Scenario: Check that module ModuleA is locked
            When I successfully run "dnf module lock ModuleA"
            Then a module ModuleA config file should contain
               | Key    | Value |
               | locked | 1     |
    """
    modulename = modulename.strip('"')
    skv_table = table_utils.convert_table_kv_to_skv(ctx.table, HEADINGS_INI, [modulename])
    ctx.table = skv_table
    filepath = '/etc/dnf/modules.d/{!s}.module'.format(modulename)
    step_an_ini_file_filepath_should_contain(ctx, filepath)
