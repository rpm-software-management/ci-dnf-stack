from __future__ import absolute_import
from __future__ import unicode_literals

from behave import given
from behave import step
from behave.model import Table
import six
from six.moves import configparser
import sys
import os

import file_utils
import table_utils

HEADINGS_INI = ["Section", "Key", "Value"]

def conf2table(configuration):
    """
    :param configparser.ConfigParser configuration: Configuration
    :return: Table
    :rtype: behave.model.Table
    """
    table = Table(HEADINGS_INI)

    def s2s(s):
        return six.text_type(s, "utf-8") if six.PY2 else s
    for section in configuration.sections():
        for key, value in configuration.items(section):
            table.add_row([s2s(section), s2s(key), s2s(value)])
    return table

@given('a file "{filepath}" with')
def step_a_file_filepath_with(ctx, filepath):
    """
    Create/Re-Create file (``{filepath}``) and write multiline text inside
    with newline at the end of file.

    .. note::

       Automatically creates all leading directories.
    """
    ctx.assertion.assertIsNotNone(ctx.text, "Multiline text is not provided")
    file_utils.create_file_with_contents(filepath, ctx.text)

@step('a file "{filepath}" exists')
def step_a_file_filepath_exists(ctx, filepath):
    ctx.assertion.assertTrue(os.path.exists(filepath))

@step('a file "{filepath}" does not exist')
def step_a_file_filepath_does_not_exist(ctx, filepath):
    ctx.assertion.assertFalse(os.path.exists(filepath))

@given('an INI file "{filepath}" with')
def step_an_ini_file_filepath_with(ctx, filepath):
    """
    Same as
    :ref:`Given a file "{filepath}" with`, but accepts table with
    sections/keys/values structure to construct INI file.

    Requires table with following headers:

    ========= ===== =======
     Section   Key   Value 
    ========= ===== =======

    Examples:

    .. code-block:: gherkin

       Feature: Creating INI files
         Scenario: Empty section
            Given an INI file "/etc/dnf/plugins/debuginfo-install.conf" with
               | Section | Key      | Value                      |
               | main    |          |                            |
         Scenario: Section with one key
            Given an INI file "/etc/dnf/plugins/debuginfo-install.conf" with
               | Section | Key      | Value                      |
               | main    | enabled  | False                      |
         Scenarion: Section with multiple keys
            Given an INI file "/etc/yum.repos.d/mnt.repo" with
               | Section | Key      | Value                      |
               | mnt     | name     | Mounted repo - $basearch   |
               |         | baseurl  | file:///mnt/repo/$basearch |
               |         | enabled  | True                       |
               |         | gpgcheck | False                      |
    """
    sections = table_utils.parse_skv_table(ctx, HEADINGS_INI)
    conf = configparser.ConfigParser()
    for section, settings in sections.items():
        if six.PY2:
            conf.add_section(section)
            for key, value in settings.items():
                conf.set(section, key, value)
        else:
            conf[section] = settings

    file_utils.create_file_with_contents(filepath, conf)

@given('an INI file "{filepath}" modified with')
def step_an_ini_file_filepath_modified_with(ctx, filepath):
    """
    Similar to
    :ref:`Given an INI file "{filepath}" with`, but accepts table with
    modifications that should be made in the respective INI file.

    Requires table with following headers:

    ========= ===== =======
     Section   Key   Value 
    ========= ===== =======

    Examples:

    .. code-block:: gherkin

       Feature: Modifying an INI file
         Scenario: Editing /etc/dnf/dnf.conf
            Given an INI file "/etc/dnf/dnf.conf" modified with
               | Section | Key        | Value |
               | main    | debuglevel | 1     |
               |         | -gpgcheck  |       |

    .. note::

       Section or Key prefixed with '-' results in the removal
       of the respective record.
    """
    updates = table_utils.parse_skv_table(ctx, HEADINGS_INI)
    sections = list(updates.keys())  # convert to list as py3 returns an iterator
    sections.sort()  # sort so we have removal first
    conf = configparser.ConfigParser()
    conf.read(filepath)
    for section in sections:
        settings = updates[section]
        if section.startswith("-"):
            section = section[1:]
            ctx.assertion.assertTrue(conf.remove_section(section), "No such section '%s' in '%s'" % (section, filepath))
        else:
            if not conf.has_section(section):
                conf.add_section(section)
            keys = settings.keys()
            for key in keys:
                if key.startswith("-"):
                    key = key[1:]
                    ctx.assertion.assertTrue(conf.remove_option(section, key), "No such key '%s' in section '%s' in '%s'" % (key, section, filepath))
                else:
                    conf.set(section, key, settings[key])
    file_utils.create_file_with_contents(filepath, conf)


@then('an INI file "{filepath}" should contain')
def step_an_ini_file_filepath_should_contain(ctx, filepath, extra_value_processing=False):
    """
    Tests whether an INI file contain respective Section, Key, Value
    triples.

    Requires table with following headers:

    ========= ===== =======
     Section   Key   Value
    ========= ===== =======

    Examples:

    .. code-block:: gherkin

       Feature: Testing an INI file content
         Scenario: Check if repozitory Test was enabled
            Then an INI file "/etc/yum.repos.d/test.repo" should contain
               | Section | Key        | Value |
               | Test    | enabled    | True  |
    """
    ini_table = table_utils.parse_skv_table(ctx, HEADINGS_INI)
    sections = ini_table.keys()
    conf = configparser.ConfigParser()
    conf.read(filepath)
    for section in sections:
        settings = ini_table[section]
        ctx.assertion.assertTrue(conf.has_section(section), "No such section '%s' in '%s'" % (section, filepath))
        keys = settings.keys()
        for key in keys:
            ctx.assertion.assertTrue(conf.has_option(section, key),
                                     "No such option '%s' in section '%s' in '%s'" % (key, section, filepath))
            value = settings[key]
            ini_value = conf.get(section, key)
            if not extra_value_processing:
                ctx.assertion.assertEqual(value, ini_value)
            else:  # an extra processing is enabled
                if value.startswith('(set)'):
                    # consider the value to be command or \n separated set of values
                    value_set = map(str.strip, value[5:].split(","))
                    ini_value_set = map(str.strip, ini_value.replace("\n", ",").split(","))
                    ctx.assertion.assertCountEqual(value_set, ini_value_set)
                else:  # fallback
                    ctx.assertion.assertEqual(value, ini_value)


@given('I run steps from file "{filepath}"')
def step_i_run_steps_from_file(ctx, filepath):
    """
    Runs all the steps from the given file (``{filepath}``).
    The file with steps is searched at a provided location
    and in case it is not found, the filename is searched also
    in a directory saved in the BEHAVE_FEATUREDIR environment
    variable or under the /tests directory.
    *.feature files but should not have *.feature suffix
    so it won't be executed on its own. Also, the file
    should contain only steps, there should be no
    Feature: or Scenario: descriptions.
    """
    if not os.path.isfile(filepath):  # there is no such file, I will try to check other locations
        # first check if the user exported the environment variable BEHAVE_FEATUREDIR
        filename = os.path.basename(filepath)
        if os.environ.get('BEHAVE_FEATUREDIR'):
            filepath = os.path.join(os.environ.get('BEHAVE_FEATUREDIR'), filename.lstrip('/'))
        # try the /tests/ directory used in Docker image
        else:
            filepath = os.path.join('/tests/', filename.lstrip('/'))
        if not os.path.isfile(filepath):
            raise AssertionError('Cannot find the file "%s", try exporting the BEHAVE_FEATUREDIR variable properly' % filepath)
    with open(filepath, 'r') as f:
        steps = f.read()
    # print the steps to ease the debugging
    sys.stdout.write('Running sub-steps from file %s:\n' % filepath)
    sys.stdout.write('%s\n' % steps)
    ctx.execute_steps(six.text_type(steps))
