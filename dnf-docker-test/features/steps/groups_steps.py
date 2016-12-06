from behave import given
import table_utils

import jinja2
from whichcraft import which

from command_steps import step_i_successfully_run_command

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

REPO_TMPL = "/etc/yum.repos.d/{!s}.repo"

JINJA_ENV = jinja2.Environment(undefined=jinja2.StrictUndefined)


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
    GROUP_TAGS = ['is_default', 'is_uservisible', 'description'] + \
                  GROUP_TAGS_REPEATING
    pkg_groups = table_utils.parse_skv_table(ctx, HEADINGS_GROUP,
                                             GROUP_TAGS, GROUP_TAGS_REPEATING)

    createrepo = which("createrepo_c")
    ctx.assertion.assertIsNotNone(createrepo, "createrepo_c is required")

    # parse existing repo dir from the repo file
    repofile = REPO_TMPL.format(repository)
    rf = open(repofile, 'r')
    repodir = ''
    for line in rf.readlines():
        if line.startswith('baseurl = file://'):
            repodir = line[17:].strip()
    rf.close()

    # prepare the comps.xml
    comps_xml = COMPS_PREFIX
    template = JINJA_ENV.from_string(COMPS_TMPL)
    for name, settings in pkg_groups.items():
        settings = {k.lower(): v for k, v in settings.items()}
        comps_xml += template.render(name=name, **settings)
    comps_xml += COMPS_SUFFIX

    # save comps.xml and recreate the repo
    f_comps = open(repodir+'/comps.xml', 'w')
    f_comps.write(comps_xml)
    f_comps.close()
    cmd = "{!s} -g comps.xml --update {!s}".format(createrepo, repodir)
    step_i_successfully_run_command(ctx, cmd)
