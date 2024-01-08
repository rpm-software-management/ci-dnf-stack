Feature: Tests for pre-transaction-actions plugin


Background:
  Given I enable plugin "pre-transaction-actions"
    And I configure dnf with
      | key            | value                                     |
      | pluginconfpath | {context.dnf.installroot}/etc/dnf/plugins |
    And I create and substitute file "/etc/dnf/plugins/pre-transaction-actions.conf" with
    """
    [main]
    enabled = 1
    actiondir = {context.dnf.installroot}/etc/dnf/plugins/pre-transaction-actions.d/
    """
    And I use repository "dnf-ci-fedora"


Scenario: Variables in action files are substituted
  Given I create and substitute file "/etc/dnf/plugins/pre-transaction-actions.d/test.action" with
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


Scenario Outline: I can filter on package or file: "<filter>"
  Given I create and substitute file "/etc/dnf/plugins/pre-transaction-actions.d/test.action" with
    """
    <filter>:any:echo '${{state}} ${{name}}-${{epoch}}:${{ver}}-${{rel}}.${{arch}} repo ${{repoid}}' >> {context.dnf.installroot}/trans.log
    """
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
       | Action        | Package                                   |
       | install       | glibc-0:2.28-9.fc29.x86_64                |
       | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
       | install-dep   | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
       | install-dep   | glibc-common-0:2.28-9.fc29.x86_64         |
       | install-dep   | filesystem-0:3.9-2.fc29.x86_64            |
       | install-dep   | basesystem-0:11-6.fc29.noarch             |
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


Scenario Outline: I can filter on transaction state
  Given I create and substitute file "/etc/dnf/plugins/pre-transaction-actions.d/test.action" with
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


Scenario: Do not traceback when reason change is in transaction
  Given I create and substitute file "/etc/dnf/plugins/pre-transaction-actions.d/test.action" with
    """
    *:any:echo '${{state}} ${{name}}-${{epoch}}:${{ver}}-${{rel}}.${{arch}} repo ${{repoid}}' > {context.dnf.installroot}/trans.log
    """
    And I use repository "installonly"
    And I configure dnf with
        | key                          | value         |
        | installonlypkgs              | installonlyA  |
        | installonly_limit            | 2             |
   When I execute dnf with args "-v install installonlyA-1.0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                         |
        | install       | installonlyA-1.0-1.x86_64       |
    And stderr does not contain "Traceback"
    And file "/trans.log" contents is
    """
    install installonlyA-0:1.0-1.x86_64 repo installonly
    """
   When I execute dnf with args "-v install installonlyA-2.0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                         |
        | install       | installonlyA-2.0-1.x86_64       |
    And stderr does not contain "Traceback"
    And file "/trans.log" contents is
    """
    install installonlyA-0:2.0-1.x86_64 repo installonly
    """
   When I execute dnf with args "-v install installonlyA-2.2"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                         |
        | install       | installonlyA-2.2-1.x86_64       |
        | remove        | installonlyA-1.0-1.x86_64       |
    And stderr does not contain "Traceback"
    And file "/trans.log" contents is
    """
    install installonlyA-0:2.2-1.x86_64 repo installonly
    """
