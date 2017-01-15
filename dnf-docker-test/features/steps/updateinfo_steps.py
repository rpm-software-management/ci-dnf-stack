#!/usr/bin/python

import os
import tempfile
import table_utils
import updateinfo_utils
from whichcraft import which

from behave import given
from command_steps import step_i_successfully_run_command


@given('updateinfo defined in repository "{repository}"')
def step_updateinfo_defined_in_repository(ctx, repository):
    """
    For a given repository creates updateinfo.xml file with described
    updates and recreates the repo

    .. note::

       Requires *modifyrepo_c* and the repo to be already created.

    Requires table with following headers:

    ==== ===== =======
     Id   Tag   Value
    ==== ===== =======

    *Tag* is describing attributes of the respective update.
    Supported tags are:

    ============ =========================
         Tag      Default value
    ============ =========================
    Title        Default title of Id
    Type         security
    Description  Default description of Id
    Summary      Default summary of Id
    Severity     Low
    Solution     Default solution of Id
    Rights       nobody
    Issued       2017-01-01 00:00:01
    Updated      2017-01-01 00:00:01
    Reference    none
    Package      none
    ============ =========================

    Examples:

    .. code-block:: gherkin

       Feature: Defining updateinfo in a repository

         @setup
         Scenario: Repository base with updateinfo defined
              Given repository "base" with packages
                 | Package | Tag     | Value |
                 | foo     | Version | 2     |
                 | bar     | Version | 2     |
              And updateinfo defined in repository "base"
                 | Id            | Tag         | Value                     |
                 | RHSA-2017-001 | Title       | foo bar security update   |
                 |               | Type        | security                  |
                 |               | Description | Fixes buffer overflow     |
                 |               | Summary     | Critical bug is fixed     |
                 |               | Severity    | Critical                  |
                 |               | Solution    | Update to the new version |
                 |               | Rights      | Copyright 2017 Baz Inc    |
                 |               | Reference   | CVE-2017-0001             |
                 |               | Reference   | BZ123456                  |
                 |               | Package     | foo-2                     |
                 |               | Package     | bar-2                     |

    .. note::

       Specifying Version or Release in Package tag is not necessary, however
       when multiple RPMs matches the string the last one from the sorted
       list is used.
    """
    HEADINGS_GROUP = ['Id', 'Tag', 'Value']
    UPDATEINFO_TAGS_REPEATING = ['Package', 'Reference']
    UPDATEINFO_TAGS = ['Title', 'Type', 'Description', 'Solution', 'Summary', 'Severity', 'Rights', 'Issued', 'Updated'] + \
                      UPDATEINFO_TAGS_REPEATING
    updateinfo_table = table_utils.parse_skv_table(ctx, HEADINGS_GROUP, UPDATEINFO_TAGS, UPDATEINFO_TAGS_REPEATING)

    # verify that modifyrepo_c is present
    modifyrepo = which("modifyrepo_c")
    ctx.assertion.assertIsNotNone(modifyrepo, "modifyrepo_c is required")

    # prepare updateinfo.xml content
    repodir = updateinfo_utils.get_repo_dir(repository)
    updateinfo_xml = updateinfo_utils.get_updateinfo_xml(repository, updateinfo_table)

    # save it to the updateinfo.xml file and recreate the repodata
    tmpdir = tempfile.mkdtemp()
    with open(os.path.join(tmpdir, "updateinfo.xml"), 'w') as fw:
        fw.write(updateinfo_xml)
    cmd = "{!s} {!s} {!s}".format(modifyrepo, os.path.join(tmpdir, 'updateinfo.xml'), os.path.join(repodir, 'repodata'))
    step_i_successfully_run_command(ctx, cmd)
