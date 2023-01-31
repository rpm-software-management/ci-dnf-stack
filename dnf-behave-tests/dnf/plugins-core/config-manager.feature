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
    Command line error: one of the following arguments is required: --save --add-repo --dump --dump-variables --set-enabled --enable --set-disabled --disable
    """


@bz1782822
Scenario: when run with single argument
   When I execute dnf with args "config-manager repo1"
   Then the exit code is 1
    And stderr is
    """
    Command line error: one of the following arguments is required: --save --add-repo --dump --dump-variables --set-enabled --enable --set-disabled --disable
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


@bz1830530
Scenario Outline: enable more than one repository
   When I execute dnf with args "config-manager --enable <option>"
   Then the exit code is 0
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
        enabled=1
        gpgcheck=0
        """

Examples:
        | option         |
        | repo1 repo2    |
        | repo1,repo2    |
        | repo1, repo2   |
        | repo1 ,repo2   |
        | repo1 , repo2  |


@bz1830530
Scenario Outline: disable more than one repository
   When I execute dnf with args "config-manager --disable <option>"
   Then the exit code is 0
    And file "/etc/yum.repos.d/repo1.repo" contents is
        """
        [repo1]
        name=repo1 test repository
        enabled=0
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
        | option         |
        | repo1 repo2    |
        | repo1,repo2    |
        | repo1, repo2   |
        | repo1 ,repo2   |
        | repo1 , repo2  |


@bz1830530
Scenario Outline: enable more than one repository
Scenario: enable repo using wildcards and commas
  Given I configure a new repository "sepo1" with
        | key         | value    |
        | enabled     | 1        |
   When I execute dnf with args "config-manager --enable repo*, sepo1"
   Then the exit code is 0
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
        enabled=1
        gpgcheck=0
        """
    And file "/etc/yum.repos.d/sepo1.repo" contents is
        """
        [sepo1]
        name=sepo1 test repository
        enabled=1
        gpgcheck=0
        """


@bz1830530
Scenario Outline: enable more than one repository
Scenario: disable repo using wildcards and commas
  Given I configure a new repository "sepo1" with
        | key         | value    |
        | enabled     | 1        |
   When I execute dnf with args "config-manager --disable repo*, sepo1"
   Then the exit code is 0
    And file "/etc/yum.repos.d/repo1.repo" contents is
        """
        [repo1]
        name=repo1 test repository
        enabled=0
        gpgcheck=0
        """
    And file "/etc/yum.repos.d/repo2.repo" contents is
        """
        [repo2]
        name=repo2 test repository
        enabled=0
        gpgcheck=0
        """
    And file "/etc/yum.repos.d/sepo1.repo" contents is
        """
        [sepo1]
        name=sepo1 test repository
        enabled=0
        gpgcheck=0
        """


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


@bz1782822
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
    Command line error: one of the following arguments is required: --save --add-repo --dump --dump-variables --set-enabled --enable --set-disabled --disable
    """



@bz1782822
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
    Command line error: one of the following arguments is required: --save --add-repo --dump --dump-variables --set-enabled --enable --set-disabled --disable
    """


Scenario: config-manager --save saves to correct config file
  Given I create file "alternative.conf" with
        """
        [main]
        """
   When I execute dnf with args "config-manager --config={context.dnf.installroot}/alternative.conf --save --setopt=debuglevel=7"
   Then the exit code is 0
    And file "alternative.conf" contains lines
        """
        [main]
        debuglevel=7
        """

Scenario: config-manager --save preserves comments and empty lines
  Given I create file "/etc/yum.repos.d/emptylines.repo" with
        """
        [dummy1]
        name=Dummy repo 1
        # the comment line

        enabled=0

        baseurl=file://the/dummy1/location/

        # other comment line

        [dummy2]
        name=Dummy repo 2
        enabled=0
        baseurl=file://the/dummy2/location/

        # trailing comment
        """
   When I execute dnf with args "config-manager --set-enabled dummy1"
   Then the exit code is 0
    And file "/etc/yum.repos.d/emptylines.repo" contents is
        """
        [dummy1]
        name=Dummy repo 1
        # the comment line

        enabled=1

        baseurl=file://the/dummy1/location/

        # other comment line

        [dummy2]
        name=Dummy repo 2
        enabled=0
        baseurl=file://the/dummy2/location/

        # trailing comment
        """


Scenario: dump the "main" section
  Given I configure dnf with
        | key                   | value      |
        | best                  | 0          |
   When I execute dnf with args "config-manager --dump main"
   Then the exit code is 0
    And stdout contains "best = 0"
