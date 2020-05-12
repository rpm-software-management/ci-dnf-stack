@no_installroot
Feature: Protect running kernel


Background: Install fake kernel
  Given I use repository "protect-running-kernel"
    And I successfully execute microdnf with args "install dnf-ci-kernel"
    And I fake kernel release to "1.0"


@bz1698145
Scenario: Running kernel is protected
   When I execute microdnf with args "remove dnf-ci-kernel"
   Then the exit code is 1
    And stderr is
        """
        error: Could not depsolve transaction; 1 problem detected:
         Problem: The operation would result in removing the following protected packages: dnf-ci-kernel
        """


@bz1698145
Scenario: Running kernel is not protected with config protect_running_kernel=False
  Given I configure dnf with
        | key                       | value            |
        | protect_running_kernel    | 0                |
   When I execute microdnf with args "remove dnf-ci-kernel"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                             |
        | remove        | dnf-ci-kernel-0:1.0-1.x86_64        |


@bz1698145
Scenario: Running kernel is protected when in protected_packages even with config protect_running_kernel=False
  Given I configure dnf with
        | key                       | value            |
        | protected_packages        | dnf-ci-kernel    |
   When I execute microdnf with args "remove dnf-ci-kernel"
   Then the exit code is 1
    And stderr is
        """
        error: Could not depsolve transaction; 1 problem detected:
         Problem: The operation would result in removing the following protected packages: dnf-ci-kernel
        """


@bz1698145
Scenario: Running kernel is protected against obsoleting
   When I execute microdnf with args "install dnf-ci-obsolete"
   Then the exit code is 1
    And stderr is
        """
        error: Could not depsolve transaction; 1 problem detected:
         Problem: The operation would result in removing the following protected packages: dnf-ci-kernel
        """


@bz1698145
Scenario: Running kernel is not protected against obsoleting with config protect_running_kernel=False
  Given I configure dnf with
        | key                       | value            |
        | protect_running_kernel    | 0                |
   When I execute microdnf with args "install dnf-ci-obsolete"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                             |
        | install       | dnf-ci-obsolete-0:1.0-1.x86_64      |
        | obsoleted     | dnf-ci-kernel-0:1.0-1.x86_64        |
