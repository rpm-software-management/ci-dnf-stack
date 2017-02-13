from __future__ import absolute_import
from __future__ import unicode_literals

import jinja2
from whichcraft import which

from behave import given
from command_steps import step_i_successfully_run_command

import table_utils

GPGKEY_CONF_TMPL = """
%no-protection
%transient-key
Key-Type: {{ key_type|default("RSA") }}
Key-Length: {{ key_length|default("2048") }}
Subkey-Type: {{ subkey_type|default("RSA") }}
Subkey-Length: {{ subkey_length|default("2048") }}
Name-Real: {{ name_real|default("DNFtest") }}
Name-Comment: {{ name_comment|default("No Comment") }}
Name-Email: {{ name_email|default("dnf@noreply") }}
Expire-Date: {{ expire_date|default("0") }}
%commit
"""
GPGKEY_FILEPATH_TMPL = "/root/{!s}.{!s}"

JINJA_ENV = jinja2.Environment(undefined=jinja2.StrictUndefined)

@given('GPG key "{name_real}"')
def step_gpg_key(ctx, name_real):
    """
    Generates for the root user GPG key with a given identity,
    a.k.a. the Name-Real attribute.

    GPG key attributes can be optionally specified using the table with
    following headers:

    ======= =========
      Tag     Value  
    ======= =========

    Supported GPG key attrubutes are:

    ============= ===============
        Tag       Default value  
    ============= ===============
    Key-Type      RSA            
    Key-Length    2048           
    Subkey-Type   RSA            
    Subkey-Length 2048           
    Name-Comment  No Comment     
    Name-Email    dnf@noreply    
    Expire-Date   0              
    =============================

    .. note::
       GPG key configuration is saved in a file /root/${Name-Real}.keyconf
       respective public key is exported to a file /root/${Name-Real}.pubkey

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

    if ctx.table:  # additional GPG key configuration listed in the table
        GPGKEY_HEADINGS = ['Tag', 'Value']
        GPGKEY_TAGS = ['Key-Type', 'Key-Length', 'Subkey-Type', 'Subkey-Length', 'Name-Comment', 'Name-Email', 'Expire-Date']
        gpgkey_conf_table = table_utils.parse_kv_table(ctx, GPGKEY_HEADINGS, GPGKEY_TAGS)
    else:  # no table present
        gpgkey_conf_table = {}
    template = JINJA_ENV.from_string(GPGKEY_CONF_TMPL)
    settings = {k.lower().replace('-', '_'): v for k, v in gpgkey_conf_table.items()}
    gpgkey_conf = template.render(name_real=name_real, **settings)
    # write gpgkey configuration to a file
    fpath = GPGKEY_FILEPATH_TMPL.format(name_real, "keyconf")
    with open(fpath, 'w') as fw:
        fw.write(gpgkey_conf)
    # generate the GPG key
    gpgbin = which("gpg2")
    cmd = "{!s} --batch --gen-key '{!s}'".format(gpgbin, fpath)
    step_i_successfully_run_command(ctx, cmd)
    # export the public key
    cmd = "{!s} --export --armor '{!s}'".format(gpgbin, name_real)
    step_i_successfully_run_command(ctx, cmd)
    fpath = GPGKEY_FILEPATH_TMPL.format(name_real, "pubkey")
    with open(fpath, 'w') as fw:
        fw.write(ctx.cmd_result.stdout)


@given('GPG key "{name_real}" imported in rpm database')
def step_gpg_key_imported_in_rpm_database(ctx, name_real):
    """
    Imports the public key for the previously generated GPG key into the rpm database.

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
    pubkey = GPGKEY_FILEPATH_TMPL.format(name_real, 'pubkey')
    rpm = which("rpm")
    cmd = "{!s} --import '{!s}'".format(rpm, pubkey)
    step_i_successfully_run_command(ctx, cmd)
