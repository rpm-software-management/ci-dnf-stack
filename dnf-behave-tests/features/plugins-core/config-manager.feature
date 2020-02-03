Feature: dnf config-manager command


Background:
  Given I enable plugin "config_manager"
    And I configure a new repository "repo1" with
        | key         | value    |
        | enabled     | 1        |
    And I configure a new repository "repo2" with
        | key         | value    |
        | enabled     | 0        |


@bz1782822
Scenario: when run without arguments
   When I execute dnf with args "config-manager"
   Then the exit code is 1
    And stderr is
    """
    Command line error: one of the following arguments is required: --save --add-repo --dump --dump-variables --enable --disable
    """


Scenario: when run with single argument
   When I execute dnf with args "config-manager repo1"
   Then the exit code is 1
    And stderr is
    """
    Command line error: one of the following arguments is required: --save --add-repo --dump --dump-variables --enable --disable
    """


Scenario Outline: <option> enables given repository
   When I execute dnf with args "config-manager <option> repo2"
   Then the exit code is 0
    And file "/etc/yum.repos.d/repo2.repo" contents is
        """
        [repo2]
        name=repo2 test repository
        enabled=1
        gpgcheck=0
        """

Examples:
        | option          |
        | --enable        |
        | --set-enabled   |


Scenario Outline: <option> disables given repository
   When I execute dnf with args "config-manager <option> repo1"
   Then the exit code is 0
    And file "/etc/yum.repos.d/repo1.repo" contents is
        """
        [repo1]
        name=repo1 test repository
        enabled=0
        gpgcheck=0
        """

Examples:
        | option          |
        | --disable       |
        | --set-disabled  |


@bz1679213
Scenario: --enable enables repository specified in --setopt option
   When I execute dnf with args "config-manager --enable --setopt=repo2.gpgcheck=1"
   Then the exit code is 0
    And file "/etc/yum.repos.d/repo2.repo" contents is
        """
        [repo2]
        name=repo2 test repository
        enabled=1
        gpgcheck=1
        """


@bz1679213
Scenario: --disable disables repository specified in --setopt option
   When I execute dnf with args "config-manager --disable --setopt=repo1.gpgcheck=1"
   Then the exit code is 0
    And file "/etc/yum.repos.d/repo1.repo" contents is
        """
        [repo1]
        name=repo1 test repository
        enabled=0
        gpgcheck=1
        """


@bz1679213
Scenario Outline: <option> witout arguments has no effect
   When I execute dnf with args "config-manager <option>"
   Then the exit code is 0
    And stdout is empty
    And stderr is empty
    And file "/etc/yum.repos.d/repo1.repo" contents is
        """
        [repo1]
        name=repo1 test repository
        enabled=1
        gpgcheck=0
        """
    And file "/etc/yum.repos.d/repo2.repo" contents is
        """
        [repo2]
        name=repo2 test repository
        enabled=0
        gpgcheck=0
        """

Examples:
        | option          |
        | --enable        |
        | --disable       |


Scenario: --setopt modifies repo when used with --save
   When I execute dnf with args "config-manager --setopt=repo1.gpgcheck=1 --save"
   Then the exit code is 0
    And file "/etc/yum.repos.d/repo1.repo" contents is
        """
        [repo1]
        name=repo1 test repository
        enabled=1
        gpgcheck=1
        """


Scenario: --setopt does not modify repo when used without --save
   When I execute dnf with args "config-manager --setopt=repo1.gpgcheck=1"
   Then the exit code is 1
    And file "/etc/yum.repos.d/repo1.repo" contents is
        """
        [repo1]
        name=repo1 test repository
        enabled=1
        gpgcheck=0
        """
    And stderr is
    """
    Command line error: one of the following arguments is required: --save --add-repo --dump --dump-variables --enable --disable
    """



Scenario: --setopt does not modify repo when used without --save and one argument
   When I execute dnf with args "config-manager --setopt=repo1.gpgcheck=1 repo1"
   Then the exit code is 1
    And file "/etc/yum.repos.d/repo1.repo" contents is
        """
        [repo1]
        name=repo1 test repository
        enabled=1
        gpgcheck=0
        """
    And stderr is
    """
    Command line error: one of the following arguments is required: --save --add-repo --dump --dump-variables --enable --disable
    """
