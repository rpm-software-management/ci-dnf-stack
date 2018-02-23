from __future__ import absolute_import
from __future__ import unicode_literals

import glob
import os
import tempfile

from behave import given
from behave import register_type
from behave import then
from behave import when
from behave.model import Table
import jinja2
import parse
import six
from whichcraft import which

from command_steps import step_i_successfully_run_command
from file_steps import HEADINGS_INI
from file_steps import conf2table
from file_steps import step_a_file_filepath_with
from file_steps import step_an_ini_file_filepath_with
from file_steps import step_an_ini_file_filepath_modified_with
import file_utils
import table_utils
import repo_utils
from gpg_steps import GPGKEY_FILEPATH_TMPL

COMPS_PREFIX = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE comps PUBLIC "-//Red Hat, Inc.//DTD Comps info//EN" "comps.dtd">
<comps>
"""
COMPS_TMPL = """
  <group>
   <id>{{ name }}</id>
   <default>{{ is_default|default("false") }}</default>
   <uservisible>{{ is_uservisible|default("true") }}</uservisible>
   <display_order>1024</display_order>
   <name>{{ name }}</name>
   <description>{{ description|default("") }}</description>
    <packagelist>
{%- if mandatory is defined %}
{% for pkg in mandatory %}
      <packagereq type="mandatory">{{ pkg }}</packagereq>
{%- endfor %}
{%- endif %}
{%- if default is defined %}
{% for pkg in default %}
      <packagereq type="default">{{ pkg }}</packagereq>
{%- endfor %}
{%- endif %}
{%- if optional is defined %}
{% for pkg in optional %}
      <packagereq type="optional">{{ pkg }}</packagereq>
{%- endfor %}
{%- endif %}
{%- if conditional is defined %}
{% for pkgs in conditional %}
{% set pkgpair = pkgs.split(' ') %}
      <packagereq type="conditional" requires="{{ pkgpair[1] }}">{{ pkgpair[0] }}</packagereq>
{%- endfor %}
{%- endif %}
    </packagelist>
  </group>
"""
COMPS_SUFFIX = """</comps>"""

PKG_TMPL = """
Name:           {{ name }}
Summary:        {{ summary|default("Empty") }}
Version:        {{ version|default("1") }}
Release:        {{ release|default("1") }}

License:        {{ license|default("Public Domain") }}

{%- if arch is not defined or arch == "noarch" %}
BuildArch:      noarch
{%- endif %}

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

{%- if requires_pretrans is defined %}
{% for req in requires_pretrans %}
Requires(pretrans):  {{ req }}
{%- endfor %}
{%- endif %}

{%- if requires_pre is defined %}
{% for req in requires_pre %}
Requires(pre):  {{ req }}
{%- endfor %}
{%- endif %}

{%- if requires_post is defined %}
{% for req in requires_post %}
Requires(post):  {{ req }}
{%- endfor %}
{%- endif %}

{%- if requires_preun is defined %}
{% for req in requires_preun %}
Requires(preun):  {{ req }}
{%- endfor %}
{%- endif %}

{%- if recommends is defined %}
{% for rec in recommends %}
Recommends:     {{ rec }}
{%- endfor %}
{%- endif %}

{%- if suggests is defined %}
{% for sug in suggests %}
Suggests:       {{ sug }}
{%- endfor %}
{%- endif %}

{%- if supplements is defined %}
{% for sup in supplements %}
Supplements:    {{ sup }}
{%- endfor %}
{%- endif %}

{%- if enhances is defined %}
{% for enh in enhances %}
Enhances:       {{ enh }}
{%- endfor %}
{%- endif %}

{%- if obsoletes is defined %}
{% for obs in obsoletes %}
Obsoletes:      {{ obs }}
{%- endfor %}
{%- endif %}

{%- if conflicts is defined %}
{% for con in conflicts %}
Conflicts:       {{ con }}
{%- endfor %}
{%- endif %}

{%- if provides is defined %}
{% for prv in provides %}
Provides:       {{ prv }}
{%- endfor %}
{%- endif %}

{%- if _pretrans is defined %}
%pretrans
{% for line in _pretrans %}
{{ line }}
{%- endfor %}
{%- endif %}

{%- if _pre is defined %}
%pre
{% for line in _pre %}
{{ line }}
{%- endfor %}
{%- endif %}

{%- if _post is defined %}
%post
{% for line in _post %}
{{ line }}
{%- endfor %}
{%- endif %}

{%- if _preun is defined %}
%preun
{% for line in _preun %}
{{ line }}
{%- endfor %}
{%- endif %}

{%- if _postun is defined %}
%postun
{% for line in _postun %}
{{ line }}
{%- endfor %}
{%- endif %}

{%- if _posttrans is defined %}
%posttrans
{% for line in _posttrans %}
{{ line }}
{%- endfor %}
{%- endif %}

%description
%{summary}.

%prep
touch %{name}-%{version}-%{release}.tmp .

%install
mkdir -p %{buildroot}/usr/local/%{name}
mv %{name}-%{version}-%{release}.tmp %{buildroot}/usr/local/%{name}/

%files
/usr/local/%{name}/
/usr/local/%{name}/%{name}-%{version}-%{release}.tmp
"""
REPO_TMPL = "/etc/yum.repos.d/{!s}.repo"
HEADINGS_REPO = ["Package", "Tag", "Value"]
PKG_TAGS_REPEATING = ["BuildRequires", "Requires", "Recommends", "Suggests", "Supplements", "Enhances", "Obsoletes", "Provides", "Conflicts", "%pretrans", "%pre", "%post", "%preun", "%postun", "%posttrans", "Requires(pretrans)", "Requires(pre)", "Requires(post)", "Requires(preun)"]
PKG_TAGS = ["Summary", "Version", "Release", "License", "Arch"] + PKG_TAGS_REPEATING

JINJA_ENV = jinja2.Environment(undefined=jinja2.StrictUndefined)

@parse.with_pattern(r"enable|disable")
def parse_enable_disable(text):
    if text == "enable":
        return True
    if text == "disable":
        return False
    assert False

register_type(enable_disable=parse_enable_disable)

@parse.with_pattern(r"enabled |disabled |")
def parse_enabled_status(text):
    if text == "enabled ":
        return True
    if text == "disabled " or text == "":
        return False
    assert False

register_type(enabled_status=parse_enabled_status)

@parse.with_pattern(r"local |http |https |ftp |")
def parse_repo_type(text):
    if text == "http ":
        return "http"
    elif text == "https ":
        return "https"
    elif text == "ftp ":
        return "ftp"
    elif text == 'local ' or text == '':
        return "file"
    assert False

register_type(repo_type=parse_repo_type)

@when('I remove all repositories')
def step_i_remove_all_repositories(ctx):
    """
    Remove all ``*.repo`` files in ``/etc/yum.repos.d/``.
    """
    for f in glob.glob("/etc/yum.repos.d/*.repo"):
        os.remove(f)

@given('{enabled:enabled_status}{rtype:repo_type}repository "{repository}" with packages')
def given_repository_with_packages(ctx, enabled, rtype, repository, gpgkey=None):
    """
    Builds dummy packages, creates repo and *.repo* file.
    Supported repo types are http, https, ftp or local (default).
    Supported architectures are x86_64, i686 and noarch (default).

    .. note::

       Along with the repository also *-source repository with
       src.rpm packages is built. The repository is disabled.

    .. note::

       *https* repositories are configured to use certificates at
       following locations:
         /etc/pki/tls/certs/testcerts/ca/cert.pem
         /etc/pki/tls/certs/testcerts/client/key.pem
         /etc/pki/tls/certs/testcerts/client/cert.pem

    .. note::

       Requires *rpmbuild* and *createrepo_c*.

    Requires table with following headers:

    ========= ===== =======
     Package   Tag   Value
    ========= ===== =======

    *Tag* is tag in RPM. Supported ones are:

    ================== ===============
         Tag            Default value 
    ================== ===============
    Summary            Empty          
    Version            1              
    Release            1              
    Arch               x86_64         
    License            Public Domain  
    BuildRequires      []             
    Requires           []             
    Recommends         []             
    Suggests           []             
    Supplements        []             
    Enhances           []             
    Requires(pretrans) []             
    Requires(pre)      []             
    Requires(post)     []             
    Requires(preun)    []             
    Obsoletes          []             
    Provides           []             
    Conflicts          []             
    %pretrans          Empty          
    %pre               Empty          
    %post              Empty          
    %preun             Empty          
    %postun            Empty          
    %posttrans         Empty          
    ================== ===============

    All packages are built during step execution.

    .. note::

        *BuildRequires* are ignored for build-time (*rpmbuild* is executed
        with ``--nodeps`` option).

        If there is a space character in the package name only the preceding
        part is used.

    .. note::

        Scriptlets such as *%pre* can be listed multiple time so that the
        entering of a multi-line script is more comfortable.

    Examples:

    .. code-block:: gherkin

       Feature: Working with repositories

         Background: Repository base with dummy package
               Given http repository base with packages
                  | Package | Tag | Value |
                  | foo     |     |       |

         Scenario: Installing dummy package from background
              When I enable repository base
              Then I successfully run "dnf -y install foo"

         Scenario: Creating repository with multiple package versions
             Given http repository "updates" with packages
                | Package | Tag     | Value |
                | foo     | Version |  2.0  |
                | foo v3  | Version |  3.0  |

         Scenario: Creating a package with %pre scriptlet failing
             Given http repository "more_updates" with packages
                | Package | Tag     | Value   |
                | foo     | Version |  4.0    |
                |         | %pre    |  exit 1 |
    """
    packages = table_utils.parse_skv_table(ctx, HEADINGS_REPO,
                                           PKG_TAGS, PKG_TAGS_REPEATING)

    rpmbuild = which("rpmbuild")
    ctx.assertion.assertIsNotNone(rpmbuild, "rpmbuild is required")
    createrepo = which("createrepo_c")
    ctx.assertion.assertIsNotNone(createrepo, "createrepo_c is required")

    if rtype == 'http' or rtype == 'https':
        tmpdir = tempfile.mkdtemp(dir='/var/www/html')
        repopath = os.path.join('localhost', os.path.basename(tmpdir))
    elif rtype == 'ftp':
        tmpdir = tempfile.mkdtemp(dir='/var/ftp/pub')
        repopath = os.path.join('localhost/pub', os.path.basename(tmpdir))
    else:
        tmpdir = tempfile.mkdtemp()
        repopath = tmpdir
    srpm_tmpdir = '{}-source'.format(tmpdir.rstrip('/'))
    srpm_repopath = '{}-source'.format(repopath.rstrip('/'))
    os.mkdir(srpm_tmpdir)  # create a directory for src.rpm pkgs
    template = JINJA_ENV.from_string(PKG_TMPL)
    for name, settings in packages.items():
        name = name.split()[0]  # cut-off the pkg name _suffix_ to allow defining multiple package versions
        # before processing the template
        #   lower all characters
        #   replace '%' in Tag name with '_'
        #   replace '(' in Tag name with '_'
        #   delete all ')' in Tag
        settings = {k.lower().replace('%', '_').replace('(', '_').replace(')', ''): v for k, v in settings.items()}
        ctx.text = template.render(name=name, **settings)
        fname = "{!s}/{!s}.spec".format(tmpdir, name)
        step_a_file_filepath_with(ctx, fname)
        buildname = '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}.rpm'
        if 'arch' not in settings or settings['arch'] == 'noarch':
            cmd = "{!s} --define '_rpmdir {!s}' --define '_srcrpmdir {!s}' --define '_build_name_fmt {!s}' -ba {!s}".format(
                rpmbuild, tmpdir, srpm_tmpdir, buildname, fname)
        else:
            cmd = "setarch {!s} {!s} --define '_rpmdir {!s}' --define '_srcrpmdir {!s}' --define '_build_name_fmt {!s}' --target {!s} -ba {!s}".format(
                settings['arch'], rpmbuild, tmpdir, srpm_tmpdir, buildname, settings['arch'], fname)
        step_i_successfully_run_command(ctx, cmd)

    if gpgkey:
        # sign all rpms built
        rpmsign = which("rpmsign")
        rpms = glob.glob("{!s}/*.rpm".format(tmpdir))
        srpms = glob.glob("{!s}/*.rpm".format(srpm_tmpdir))
        cmd = "{!s} --addsign --key-id '{!s}' {!s} {!s}".format(rpmsign, gpgkey, ' '.join(rpms), ' '.join(srpms))
        step_i_successfully_run_command(ctx, cmd)

    cmd = "{!s} {!s}".format(createrepo, tmpdir)
    step_i_successfully_run_command(ctx, cmd)
    cmd = "{!s} {!s}".format(createrepo, srpm_tmpdir)
    step_i_successfully_run_command(ctx, cmd)

    # set proper directory content ownership
    file_utils.set_dir_content_ownership(ctx, tmpdir)
    file_utils.set_dir_content_ownership(ctx, srpm_tmpdir)

    repofile = REPO_TMPL.format(repository)
    ctx.table = Table(HEADINGS_INI)
    ctx.table.add_row([repository, "name",          repository])
    ctx.table.add_row(["",         "enabled",       six.text_type(enabled)])
    ctx.table.add_row(["",         "baseurl",       "{!s}://{!s}".format(rtype, repopath)])
    if gpgkey:
        ctx.table.add_row(["",     "gpgcheck",      "True"])
    else:
        ctx.table.add_row(["",     "gpgcheck",      "False"])
    if rtype == 'https':
        ctx.table.add_row(["",     "sslcacert",     "/etc/pki/tls/certs/testcerts/ca/cert.pem"])
        ctx.table.add_row(["",     "sslclientkey",  "/etc/pki/tls/certs/testcerts/client/key.pem"])
        ctx.table.add_row(["",     "sslclientcert", "/etc/pki/tls/certs/testcerts/client/cert.pem"])
    step_an_ini_file_filepath_with(ctx, repofile)
    # create -source repository too
    srpm_repository = '{}-source'.format(repository)
    repofile = REPO_TMPL.format(srpm_repository)
    ctx.table = Table(HEADINGS_INI)
    ctx.table.add_row([srpm_repository, "name",          srpm_repository])
    ctx.table.add_row(["",              "enabled",       "False"])
    ctx.table.add_row(["",              "baseurl",       "{!s}://{!s}".format(rtype, srpm_repopath)])
    if gpgkey:
        ctx.table.add_row(["",          "gpgcheck",      "True"])
    else:
        ctx.table.add_row(["",          "gpgcheck",      "False"])
    if rtype == 'https':
        ctx.table.add_row(["",          "sslcacert",     "/etc/pki/tls/certs/testcerts/ca/cert.pem"])
        ctx.table.add_row(["",          "sslclientkey",  "/etc/pki/tls/certs/testcerts/client/key.pem"])
        ctx.table.add_row(["",          "sslclientcert", "/etc/pki/tls/certs/testcerts/client/cert.pem"])
    step_an_ini_file_filepath_with(ctx, repofile)

@given('{enabled:enabled_status}{rtype:repo_type}repository "{repository}" with packages signed by "{gpgkey}"')
def given_repository_with_packages_signed_by(ctx, enabled, rtype, repository, gpgkey):
    """
    Builds a repository with packages signed by the given GPG key.

    Examples:

    .. code-block:: gherkin

       Feature: Package signatures

         Scenario: Setup repository with signed packages
           Given GPG key "James Bond"
             And GPG key "James Bond" imported in rpm database
             And repository "TestRepo" with packages signed by "James Bond"
               | Package | Tag | Value |
               | TestA   |     |       |
    """
    given_repository_with_packages(ctx, enabled, rtype, repository, gpgkey=gpgkey)

@given('repository "{repository}" metadata signed by "{gpgkey}"')
def given_repository_metadata_signed_by(ctx, repository, gpgkey):
    """
    Signs repodata.xml for a given repository using the given GPG key and
    updates the repo file with gpgkey URL.
    Should be used after the repo is created or updated.

    .. note::

        The default dnf settings is *repo_gpgcheck = False*.

    Examples:

    .. code-block:: gherkin

       Feature: Repodata signatures

         Scenario: Setup repository with signed metadata
           Given GPG key "JamesBond"
             And GPG key "JamesBond" imported in rpm database
             And repository "TestRepo" with packages signed by "JamesBond"
               | Package | Tag | Value |
               | TestA   |     |       |
             And repository "TestRepo" metadata signed by "JamesBond"
             And a repo file of repository "TestRepo" modified with
               | Key           | Value |
               | repo_gpgcheck | True  |
    """
    # sign the repomd.xml file
    repodir = repo_utils.get_repo_dir(repository)
    gpg = which("gpg2")
    cmd = "{!s} --detach-sig --armor --default-key '{!s}' {!s}/repodata/repomd.xml".format(gpg, gpgkey, repodir)
    step_i_successfully_run_command(ctx, cmd)
    # update the repo file with path to the gpg key
    pubkey = GPGKEY_FILEPATH_TMPL.format(gpgkey, "pubkey")
    keyurl = "file://{!s}".format(pubkey)
    repofile = REPO_TMPL.format(repository)
    conf = file_utils.read_ini_file(repofile)
    conf.set(repository, "gpgkey", keyurl)
    file_utils.create_file_with_contents(repofile, conf)

@given('empty repository "{repository}"')
def given_empty_repository(ctx, repository):
    """
    Same as :ref:`Given repository "{repository}" with packages`, but without
    packages (empty).
    """
    ctx.table = Table(HEADINGS_REPO)
    given_repository_with_packages(ctx, False, "file", repository)

@then('I {state:enable_disable} repository "{repository}"')
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
    repodir = repo_utils.get_repo_dir(repository)
    updateinfo_xml = repo_utils.get_updateinfo_xml(repository, updateinfo_table)

    # save it to the updateinfo.xml file and recreate the repodata
    tmpdir = tempfile.mkdtemp()
    with open(os.path.join(tmpdir, "updateinfo.xml"), 'w') as fw:
        fw.write(updateinfo_xml)
    file_utils.set_dir_content_ownership(ctx, repodir, 'root')   # change file ownership to root so we can change it
    cmd = "{!s} {!s} {!s}".format(modifyrepo, os.path.join(tmpdir, 'updateinfo.xml'), os.path.join(repodir, 'repodata'))
    step_i_successfully_run_command(ctx, cmd)
    file_utils.set_dir_content_ownership(ctx, repodir)   # restore file ownership

@given('package groups defined in repository "{repository}"')
def given_package_groups_defined_in_repository(ctx, repository):
    """
    For a given repository creates comps.xml file with described
    package groups and recreates the repo

    .. note::

       Requires *createrepo_c* and the repo to be already created.

    Requires table with following headers:

    ========= ===== =======
     Group     Tag   Value
    ========= ===== =======

    *Tag* is describing characteristics of the respective
    package group.Supported tags are:

    ============== ===============
         Tag        Default value 
    ============== ===============
    is_default          false     
    is_uservisible      true      
    description         ""        
    mandatory           []        
    default             []        
    optional            []        
    conditional         []        
    ============== ===============

    Examples:

    .. code-block:: gherkin

       Feature: Installing a package group

         @setup
         Scenario: Repository base with package group minimal
              Given repository "base" with packages
                 | Package | Tag | Value |
                 | foo     |     |       |
                 | bar     |     |       |
                 | baz     |     |       |
                 | qux     |     |       |
              And package groups defined in repository "base"
                 | Group    | Tag         | Value   |
                 | minimal  | mandatory   | foo     |
                 |          | default     | bar     |
                 |          | conditional | baz qux |

         Scenario: Installing package group from background
              When I enable repository "base"
              Then I successfully run "dnf -y group install minimal"

    .. note::

       Conditional packages are described in a form PKG REQUIREDPKG

    """
    HEADINGS_GROUP = ['Group', 'Tag', 'Value']
    GROUP_TAGS_REPEATING = ['mandatory', 'default', 'optional', 'conditional']
    GROUP_TAGS = ['is_default', 'is_uservisible', 'description'] + GROUP_TAGS_REPEATING
    pkg_groups = table_utils.parse_skv_table(ctx, HEADINGS_GROUP, GROUP_TAGS, GROUP_TAGS_REPEATING)

    createrepo = which("createrepo_c")
    ctx.assertion.assertIsNotNone(createrepo, "createrepo_c is required")

    # prepare the comps.xml
    comps_xml = COMPS_PREFIX
    template = JINJA_ENV.from_string(COMPS_TMPL)
    for name, settings in pkg_groups.items():
        settings = {k.lower(): v for k, v in settings.items()}
        comps_xml += template.render(name=name, **settings)
    comps_xml += COMPS_SUFFIX

    # save comps.xml and recreate the repo
    repodir = repo_utils.get_repo_dir(repository)
    with open(os.path.join(repodir, "comps.xml"), "w") as f_comps:
        f_comps.write(comps_xml)
    file_utils.set_dir_content_ownership(ctx, repodir, 'root')   # change file ownership to root so we can change it
    cmd = "{!s} -g comps.xml --update {!s}".format(createrepo, repodir)
    step_i_successfully_run_command(ctx, cmd)
    file_utils.set_dir_content_ownership(ctx, repodir)   # restore file ownership

@given('a repo file of repository "{repository}" modified with')
def step_a_repo_file_of_repository_modified_with(ctx, repository):
    """
    Similar to
    :ref:`Given an INI file "{filepath}" updated with`, but with
    scope limited to a particular repository identified by name.

    Requires table with following headers:

    ===== =======
     Key   Value 
    ===== =======

    Examples:

    .. code-block:: gherkin

       Feature: Modifying a repo file
         Scenario: Enabling a gpgcheck
            Given repository "TestRepoA" with packages
               | Package | Tag       | Value |
               |  TestA  |           |       |
              And a repo file of repository "TestRepoA" modified with
               | Key      | Value |
               | gpgcheck | True  |

    .. note::

       Key prefixed with '-' results in the removal of the respective
       record.
    """
    skv_table = table_utils.convert_table_kv_to_skv(ctx.table, HEADINGS_INI, [repository])
    ctx.table = skv_table
    repofile = repo_utils.REPO_TMPL.format(repository)
    step_an_ini_file_filepath_modified_with(ctx, repofile)

@given('a file "{filepath}" with type "{mdtype}" added into repository "{repository}"')
def step_a_file_with_type_added_into_repository(ctx, filepath, mdtype, repository):
    """
    Example:

    Given repository "base" with packages
        | Package | Tag     | Value |
        | TestA   | Version | 1     |
    And a file "metadata.ini" with type "newmd" added into repository "base"
        \"\"\"
        [example]
        TestA = 1
        \"\"\"
    """
    # verify that modifyrepo_c is present
    modifyrepo = which("modifyrepo_c")
    ctx.assertion.assertIsNotNone(modifyrepo, "modifyrepo_c is required")

    repodir = repo_utils.get_repo_dir(repository)

    if not os.path.isfile(filepath):
        ctx.assertion.assertIsNotNone(ctx.text, "Multiline text is not provided")
        tmpdir = tempfile.mkdtemp()
        filepath = os.path.join(tmpdir, os.path.basename(filepath))
        with open(filepath, 'w') as fw:
            fw.write(ctx.text)

    file_utils.set_dir_content_ownership(ctx, repodir, 'root')   # change file ownership to root so we can change it
    cmd = "{} --mdtype={} {} {}".format(modifyrepo, mdtype, filepath, os.path.join(repodir, "repodata"))
    step_i_successfully_run_command(ctx, cmd)
    file_utils.set_dir_content_ownership(ctx, repodir)   # restore file ownership
