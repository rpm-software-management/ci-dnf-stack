@not.with_os=rhel__eq__8
Feature: Tests for post-transaction-actions plugin


Background:
  Given I enable plugin "post-transaction-actions"
    And I create and substitute file "/etc/dnf/dnf.conf" with
    """
    [main]
    gpgcheck=1
    installonly_limit=3
    clean_requirements_on_remove=True
    pluginconfpath={context.dnf.installroot}/etc/dnf/plugins
    """
    And I create and substitute file "/etc/dnf/plugins/post-transaction-actions.conf" with
    """
    [main]
    enabled = 1
    actiondir = {context.dnf.installroot}/etc/dnf/plugins/post-transaction-actions.d/
    """
    And I do not set config file
    And I use repository "dnf-ci-fedora"


@bz967264
Scenario: Variables in action files are substituted
  Given I create and substitute file "/etc/dnf/plugins/post-transaction-actions.d/test.action" with
    """
    *:any:echo '${{state}} ${{name}}-${{epoch}}:${{ver}}-${{rel}}.${{arch}} repo ${{repoid}}' >> {context.dnf.installroot}/trans.log
    """
   When I execute dnf with args "-v install setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | setup-0:2.12.1-1.fc29.noarch          |
    And file "/trans.log" contents is
    """
    install setup-0:2.12.1-1.fc29.noarch repo dnf-ci-fedora
    """


@bz967264
Scenario Outline: I can filter on package or file: "<filter>"
  Given I create and substitute file "/etc/dnf/plugins/post-transaction-actions.d/test.action" with
    """
    <filter>:any:echo '${{state}} ${{name}}-${{epoch}}:${{ver}}-${{rel}}.${{arch}} repo ${{repoid}}' >> {context.dnf.installroot}/trans.log
    """
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
       | Action        | Package                                   |
       | install       | setup-0:2.12.1-1.fc29.noarch              |
       | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
       | install       | glibc-common-0:2.28-9.fc29.x86_64         |
       | install       | glibc-0:2.28-9.fc29.x86_64                |
       | install       | filesystem-0:3.9-2.fc29.x86_64            |
       | install       | basesystem-0:11-6.fc29.noarch             |
    And file "/trans.log" contents is
    """
    install glibc-0:2.28-9.fc29.x86_64 repo dnf-ci-fedora
    """

Examples:
    | filter            |
    | /etc/ld.so.conf   |
    | /etc/ld*conf      |
    | glibc             |
    | g*c               |


@bz967264
Scenario Outline: I can filter on transaction state
  Given I create and substitute file "/etc/dnf/plugins/post-transaction-actions.d/test.action" with
    """
    *:<state>:echo '${{state}} ${{name}}' >> {context.dnf.installroot}/trans.log
    """
    And I create file "/trans.log" with
    """
    """
   When I execute dnf with args "install setup"
   Then the exit code is 0
    And file "/trans.log" contents is
    """
    <output>
    """

Examples:
    | state     | output            |
    | any       | install setup     |
    | in        | install setup     |
    | out       |                   |

