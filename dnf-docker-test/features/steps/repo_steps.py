from __future__ import absolute_import
from __future__ import unicode_literals

import glob
import os
import tempfile

from behave import given
from behave import register_type
from behave import when
from behave.model import Table
import jinja2
import parse
from whichcraft import which

from command_steps import step_i_successfully_run_command
from file_steps import HEADINGS_INI
from file_steps import conf2table
from file_steps import step_a_file_filepath_with
from file_steps import step_an_ini_file_filepath_with
import file_utils
import table_utils

PKG_TMPL = """
Name:           {{ name }}
Summary:        {{ summary|default("Empty") }}
Version:        {{ version|default("1") }}
Release:        {{ release|default("1") }}%{?dist}

License:        {{ license|default("Public Domain") }}

BuildArch:      noarch

{%- if buildrequires is defined %}
{% for buildreq in buildrequires %}
BuildRequires:  {{ buildreq }}
{%- endfor %}
{%- endif %}

{%- if requires is defined %}
{% for req in requires %}
Requires:       {{ req }}
{%- endfor %}
{%- endif %}

{%- if obsoletes is defined %}
{% for obs in obsoletes %}
Obsoletes:      {{ obs }}
{%- endfor %}
{%- endif %}

{%- if provides is defined %}
{% for prv in provides %}
Provides:       {{ prv }}
{%- endfor %}
{%- endif %}

%description
%{summary}.

%files
"""
REPO_TMPL = "/etc/yum.repos.d/{!s}.repo"
HEADINGS_REPO = ["Package", "Tag", "Value"]
PKG_TAGS_REPEATING = ["BuildRequires", "Requires", "Obsoletes", "Provides"]
PKG_TAGS = ["Summary", "Version", "Release", "License"] + PKG_TAGS_REPEATING

JINJA_ENV = jinja2.Environment(undefined=jinja2.StrictUndefined)

@parse.with_pattern(r"enable|disable")
def parse_enable_disable(text):
    if text == "enable":
        return True
    if text == "disable":
        return False
    assert False

register_type(enable_disable=parse_enable_disable)

@when('I remove all repositories')
def step_i_remove_all_repositories(ctx):
    """
    Remove all ``*.repo`` files in ``/etc/yum.repos.d/``.
    """
    for f in glob.glob("/etc/yum.repos.d/*.repo"):
        os.remove(f)

@given('repository "{repository}" with packages')
def given_repository_with_packages(ctx, repository):
    """
    Builds dummy noarch packages, creates repo and *.repo* file.

    .. note::

       Requires *rpmbuild* and *createrepo_c*.

    Requires table with following headers:

    ========= ===== =======
     Package   Tag   Value
    ========= ===== =======

    *Tag* is tag in RPM. Supported ones are:

    ============= ===============
         Tag       Default value 
    ============= ===============
    Summary       Empty          
    Version       1              
    Release       1              
    License       Public Domain  
    BuildRequires []             
    Requires      []             
    Obsoletes     []             
    Provides      []             
    ============= ===============

    All packages are built during step execution.

    .. note::

        *BuildRequires* are ignored for build-time (*rpmbuild* is executed
        with ``--nodeps`` option).

    Examples:

    .. code-block:: gherkin

       Feature: Working with repositories

         Background: Repository base with dummy package
               Given repository base with packages
                  | Package | Tag | Value |
                  | foo     |     |       |

         Scenario: Installing dummy package from background
              When I enable repository base
              Then I successfully run "dnf -y install foo"
    """
    packages = table_utils.parse_skv_table(ctx, HEADINGS_REPO,
                                           PKG_TAGS, PKG_TAGS_REPEATING)

    rpmbuild = which("rpmbuild")
    ctx.assertion.assertIsNotNone(rpmbuild, "rpmbuild is required")
    createrepo = which("createrepo_c")
    ctx.assertion.assertIsNotNone(createrepo, "createrepo_c is required")

    tmpdir = tempfile.mkdtemp()
    template = JINJA_ENV.from_string(PKG_TMPL)
    for name, settings in packages.items():
        settings = {k.lower(): v for k, v in settings.items()}
        ctx.text = template.render(name=name, **settings)
        fname = "{!s}/{!s}.spec".format(tmpdir, name)
        step_a_file_filepath_with(ctx, fname)
        cmd = "{!s} --define '_rpmdir {!s}' -bb {!s}".format(
            rpmbuild, tmpdir, fname)
        step_i_successfully_run_command(ctx, cmd)
    cmd = "{!s} {!s}".format(createrepo, tmpdir)
    step_i_successfully_run_command(ctx, cmd)

    repofile = REPO_TMPL.format(repository)
    ctx.table = Table(HEADINGS_INI)
    ctx.table.add_row([repository, "name",     repository])
    ctx.table.add_row(["",         "enabled",  "False"])
    ctx.table.add_row(["",         "gpgcheck", "False"])
    ctx.table.add_row(["",         "baseurl",  "file://{!s}".format(tmpdir)])
    step_an_ini_file_filepath_with(ctx, repofile)

@given('empty repository "{repository}"')
def given_empty_repository(ctx, repository):
    """
    Same as :ref:`Given repository "{repository}" with packages`, but without
    packages (empty).
    """
    ctx.table = Table(HEADINGS_REPO)
    given_repository_with_packages(ctx, repository)

@when('I {state:enable_disable} repository "{repository}"')
def i_enable_disable_repository(ctx, state, repository):
    """
    Enable/Disable repository with given name.
    """
    repofile = REPO_TMPL.format(repository)
    conf = file_utils.read_ini_file(repofile)
    conf.set(repository, "enabled", str(state))
    ctx.table = conf2table(conf)
    step_an_ini_file_filepath_with(ctx, repofile)
