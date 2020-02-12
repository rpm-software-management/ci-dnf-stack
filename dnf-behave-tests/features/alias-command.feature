# Aliases config path cannot be changed, so it cannot be taken from installroot
@no_installroot
Feature: Test for alias command

Background:
  Given I delete directory "/etc/dnf/aliases.d/"
    And I delete file "/etc/yum.repos.d/*.repo" with globs
    And I delete directory "/var/lib/dnf/modulefailsafe/"
    And I use repository "alias-command"


Scenario: Add alias
   When I execute dnf with args "alias add inthrone=install"
   Then the exit code is 0
    And stdout is
        """
        Aliases added: inthrone
        """


@bz1666325
Scenario: List aliases
   When I execute dnf with args "alias add inthrone=install"
   Then the exit code is 0
   When I execute dnf with args "alias list"
   Then the exit code is 0
    And stdout is
        """
        Alias inthrone='install'
        """


@bz1680488
Scenario: List aliases with trivial infinite recursion
 When I execute dnf with args "alias add install='install dnf-ci-packageC'"
 Then the exit code is 0
  And stdout is
      """
      Aliases added: install
      """
   When I execute dnf with args "alias list"
   Then the exit code is 0
    And stderr is
        """
        Aliases contain infinite recursion, alias install="install dnf-ci-packageC"
        """
   When I execute dnf with args "install dnf-ci-packageB"
   Then the exit code is 1
    And stderr is
        """
        Aliases contain infinite recursion, using original arguments.
        Error: Unable to find a match: dnf-ci-packageB
        """


@bz1680488
Scenario: List aliases with non-trivial infinite recursion
 When I execute dnf with args "alias add install='inthrone dnf-ci-packageC' inthrone=install"
 Then the exit code is 0
  And stdout is
      """
      Aliases added: install, inthrone
      """
   When I execute dnf with args "alias list"
   Then the exit code is 0
    And stderr is
        """
        Aliases contain infinite recursion, alias install="inthrone dnf-ci-packageC"
        Aliases contain infinite recursion, alias inthrone="install"
        """
   When I execute dnf with args "install dnf-ci-packageB"
   Then the exit code is 1
    And stderr is
        """
        Aliases contain infinite recursion, using original arguments.
        Error: Unable to find a match: dnf-ci-packageB
        """


Scenario: Use alias
   When I execute dnf with args "alias add inthrone=install"
   Then the exit code is 0
   When I execute dnf with args "install dnf-ci-packageB"
   Then the exit code is 1
    And stderr is
        """
        Error: Unable to find a match: dnf-ci-packageB
        """


Scenario: Delete alias
   When I execute dnf with args "alias add inthrone=install"
   Then the exit code is 0
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
   When I execute dnf with args "inthrone dnf-ci-packageB"
   Then the exit code is 1
    And stderr contains "No such command: inthrone"


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
   When I execute dnf with args "inthrone dnf-ci-packageB"
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
   When I execute dnf with args "inthrone dnf-ci-packageB"
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
   When I execute dnf with args "inthrone dnf-ci-packageB"
   Then the exit code is 1
    And stderr is
        """
        Error: Unable to find a match: dnf-ci-packageB
        """


@bz1680482
Scenario: Backslash ends the recursive processing and the '\' is stripped
  Given I successfully execute dnf with args "alias add install='\install'"
   When I execute dnf with args "install dnf-ci-packageB"
   Then the exit code is 1
    And stderr is
        """
        Error: Unable to find a match: dnf-ci-packageB
        """
