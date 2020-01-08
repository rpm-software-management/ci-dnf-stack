# Aliases config path cannot be changed, so it cannot be taken from installroot
@no_installroot
Feature: Test for alias command

Background:
  Given I delete directory "/etc/dnf/aliases.d/"
    And I delete file "/etc/yum.repos.d/*.repo" with globs
   When I execute dnf with args "alias add inthrone=install"
   Then the exit code is 0
    And stdout is
        """
        Aliases added: inthrone
        """


Scenario: Add alias


@bz1666325
Scenario: List aliases
   When I execute dnf with args "alias list"
   Then the exit code is 0
    And stdout is
        """
        Alias inthrone='install'
        """


Scenario: Use alias
  Given I use repository "alias-command"
   When I execute dnf with args "inthrone dnf-ci-package"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | dnf-ci-package-0:1.0-1.x86_64         |
  Given I successfully execute dnf with args "remove dnf-ci-package"


Scenario: Delete alias
   When I execute dnf with args "alias delete inthrone"
   Then the exit code is 0
    And stdout is
        """
        Aliases deleted: inthrone
        """
   When I execute dnf with args "alias list"
   Then the exit code is 0
    And stdout is
        """
        No aliases defined.
        """
  Given I use repository "alias-command"
   When I execute dnf with args "inthrone dnf-ci-package"
   Then the exit code is 1
    And stderr contains "No such command: inthrone"
  Given I successfully execute dnf with args "remove dnf-ci-package"


@bz1680489
Scenario: Aliases conflicts: USER.conf has the highest priority, then alphabetical ordering is used
      # Multiple config files to decrease the randomness aspect
  Given I create file "/etc/dnf/aliases.d/A.conf" with
        """
        [aliases]
        test0 = commandA
        test1 = commandA
        test2 = commandA
        test3 = commandA
        test4 = commandA
        """
    And I create file "/etc/dnf/aliases.d/Z.conf" with
        """
        [aliases]
        test0 = commandZ
        test1 = commandZ
        """
    And I create file "/etc/dnf/aliases.d/B.conf" with
        """
        [aliases]
        test0 = commandB
        test1 = commandB
        test2 = commandB
        test3 = commandB
        """
    And I create file "/etc/dnf/aliases.d/USER.conf" with
        """
        [aliases]
        test0 = commandU
        """
    And I create file "/etc/dnf/aliases.d/C.conf" with
        """
        [aliases]
        test0 = commandC
        test1 = commandC
        test2 = commandC
        """
   When I execute dnf with args "alias"
   Then stdout is
        """
        Alias test0='commandU'
        Alias test1='commandZ'
        Alias test2='commandC'
        Alias test3='commandB'
        Alias test4='commandA'
        """


@bz1680566
Scenario: ALIASES.conf can disable all aliases
  Given I create file "/etc/dnf/aliases.d/ALIASES.conf" with
        """
        [main]
        enabled = 0
        """
    And I create file "/etc/dnf/aliases.d/custom.conf" with
        """
        [main]
        enabled = 1
        [aliases]
        inthrone = install
        """
    And I use repository "alias-command"
   When I execute dnf with args "inthrone dnf-ci-package"
   Then the exit code is 1
    And stderr contains "No such command: inthrone"


@bz1680566
Scenario: Aliases can be disabled in individual conf files
  Given I create file "/etc/dnf/aliases.d/ALIASES.conf" with
        """
        [main]
        enabled = 1
        """
    And I create file "/etc/dnf/aliases.d/USER.conf" with
        """
        [main]
        enabled = 0
        [aliases]
        inthrone = install
        """
    And I use repository "alias-command"
   When I execute dnf with args "inthrone dnf-ci-package"
   Then the exit code is 1
    And stderr contains "No such command: inthrone"


@bz1680566
Scenario: One disabled config does not affect others
  Given I create file "/etc/dnf/aliases.d/ALIASES.conf" with
        """
        [main]
        enabled = 1
        """
    And I create file "/etc/dnf/aliases.d/USER.conf" with
        """
        [main]
        enabled = 0
        [aliases]
        inthrone = install
        """
    And I create file "/etc/dnf/aliases.d/custom.conf" with
        """
        [main]
        enabled = 1
        [aliases]
        inthrone = install
        """
    And I use repository "alias-command"
   When I execute dnf with args "inthrone dnf-ci-package"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | dnf-ci-package-0:1.0-1.x86_64         |
  Given I successfully execute dnf with args "remove dnf-ci-package"
