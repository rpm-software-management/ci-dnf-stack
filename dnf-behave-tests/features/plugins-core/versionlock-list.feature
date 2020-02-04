Feature: Tests missing or misconfigured versionlock.list file in versionlock plugin


Background: Set up versionlock infrastructure in the installroot
  Given I enable plugin "versionlock"
  # plugins do not honor installroot when searching their configuration
  # all the next steps are merely to set up versionlock plugin inside installroot
  And I create and substitute file "/etc/dnf/dnf.conf" with
    """
    [main]
    gpgcheck=1
    installonly_limit=3
    clean_requirements_on_remove=True
    pluginconfpath={context.dnf.installroot}/etc/dnf/plugins
    """
  And I create and substitute file "/etc/dnf/plugins/versionlock.conf" with
    """
    [main]
    enabled = 1
    locklist = {context.dnf.installroot}/etc/dnf/plugins/versionlock.list
    """
  And I create file "/etc/dnf/plugins/versionlock.list" with
    """
    """
  And I do not set config file
  # check that both locked and newer versions of the package are available
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"


@not.with_os=rhel__eq__8
Scenario: dnf will fail if versionlock.list file is missing
  Given I delete file "/etc/dnf/plugins/versionlock.list"
  When I execute dnf with args "check-update"
  Then the exit code is 1


@not.with_os=rhel__eq__8
Scenario: dnf will fail if versionlock.list path is missing from conf
  Given I create file "/etc/dnf/plugins/versionlock.conf" with
    """
    [main]
    enabled=1
    """
  When I execute dnf with args "check-update"
  Then the exit code is 1


@not.with_os=rhel__eq__8
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


@not.with_os=rhel__eq__8
Scenario: dnf versionlock clear will create empty file if versionlock.list is missing
  Given I delete file "/etc/dnf/plugins/versionlock.list"
  When I execute dnf with args "versionlock clear"
  Then the exit code is 0
  And file "/etc/dnf/plugins/versionlock.list" exists
  And file "/etc/dnf/plugins/versionlock.list" contents is
    """
    """

@not.with_os=rhel__eq__8
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
