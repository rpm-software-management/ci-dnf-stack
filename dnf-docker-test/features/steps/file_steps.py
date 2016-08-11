from __future__ import absolute_import
from __future__ import unicode_literals

from behave import given
from behave.model import Table
import six
from six.moves import configparser

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
