Feature: Tests missing or misconfigured versionlock.list file in versionlock plugin


Background: Set up versionlock infrastructure in the installroot
  Given I enable plugin "versionlock"
  # plugins do not honor installroot when searching their configuration
  # all the next steps are merely to set up versionlock plugin inside installroot
  And I configure dnf with
    | key            | value                                     |
    | pluginconfpath | {context.dnf.installroot}/etc/dnf/plugins |
  And I create and substitute file "/etc/dnf/plugins/versionlock.conf" with
    """
    [main]
    enabled = 1
    locklist = {context.dnf.installroot}/etc/dnf/plugins/versionlock.list
    """
  And I create file "/etc/dnf/plugins/versionlock.list" with
    """
    """
  # check that both locked and newer versions of the package are available
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"


Scenario: dnf will fail if versionlock.list file is missing
  Given I delete file "/etc/dnf/plugins/versionlock.list"
  When I execute dnf with args "check-update"
  Then the exit code is 1


Scenario: dnf will fail if versionlock.list path is missing from conf
  Given I create file "/etc/dnf/plugins/versionlock.conf" with
    """
    [main]
    enabled=1
    """
  When I execute dnf with args "check-update"
  Then the exit code is 1


Scenario Outline: dnf versionlock <option> <package> will fail if versionlock.list file is missing
  Given I delete file "/etc/dnf/plugins/versionlock.list"
  When I execute dnf with args "versionlock <option> <package>"
  Then the exit code is 1

Examples:
        | option  | package |
        | list    |         |
        | delete  | abcde   |
        | add     | abcde   |
        | exclude | abcde   |


Scenario: dnf versionlock clear will create empty file if versionlock.list is missing
  Given I delete file "/etc/dnf/plugins/versionlock.list"
  When I execute dnf with args "versionlock clear"
  Then the exit code is 0
  And file "/etc/dnf/plugins/versionlock.list" exists
  And file "/etc/dnf/plugins/versionlock.list" contents is
    """
    """


Scenario Outline: dnf versionlock <option> <package> will fail if versionlock.list path is missing from conf
  Given I create file "/etc/dnf/plugins/versionlock.conf" with
    """
    [main]
    enabled=1
    """
  When I execute dnf with args "versionlock <option> <package>"
  Then the exit code is 1

Examples:
        | option    | package |
        | list      |         |
        | clear     |         |
        | add       | abcde   |
        | delete    | abcde   |
        | exclude   | abcde   |
