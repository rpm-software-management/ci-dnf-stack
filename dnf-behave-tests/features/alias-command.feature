Feature: Test for alias command

Background:
   When I execute dnf with args "alias add inthrone=install"
   Then the exit code is 0
    And stdout contains "^Aliases added: inthrone$"


Scenario: Add alias


@bz1666325
Scenario: List aliases
   When I execute dnf with args "alias list"
   Then the exit code is 0
   And stdout contains "Alias inthrone='install'"


Scenario: Use alias
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "inthrone setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


Scenario: Delete alias
   When I execute dnf with args "alias delete inthrone"
   Then the exit code is 0
    And stdout contains "^Aliases deleted: inthrone$"
   When I execute dnf with args "alias list"
   Then the exit code is 0
   And stdout does not contain "Alias inthrone"
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "inthrone setup"
   Then the exit code is 1
    And stderr contains "No such command: inthrone"


# Aliases config path cannot be changed, so it cannot be taken from installroot
@no_installroot
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
