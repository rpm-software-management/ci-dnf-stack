@dnf5
Feature: Protect running kernel


Background: Install fake kernel
  Given I use repository "protect-running-kernel"
    And I successfully execute microdnf with args "install dnf-ci-kernel --exclude dnf-ci-obsolete"
    And I fake kernel release to "1.0"


@bz1698145
Scenario: Running kernel is protected
   When I execute microdnf with args "remove dnf-ci-kernel"
   Then the exit code is 1
    And stderr is
        """
        Failed to resolve the transaction:
        Problem: The operation would result in removing of running kernel: dnf-ci-kernel-0:1.0-1.x86_64
        """


@bz1698145
Scenario: Running kernel is not protected with config protect_running_kernel=False
  Given I configure dnf with
        | key                       | value            |
        | protect_running_kernel    | 0                |
   When I execute microdnf with args "remove dnf-ci-kernel"
   Then the exit code is 0
    And transaction is following
        | Action        | Package                             |
        | remove        | dnf-ci-kernel-0:1.0-1.x86_64        |
        | remove-unused | dnf-ci-systemd-0:1.0-1.x86_64       |


@bz1698145
Scenario: Running kernel is protected when in protected_packages even with config protect_running_kernel=False
  Given I configure dnf with
        | key                       | value            |
        | protected_packages        | dnf-ci-kernel    |
   When I execute microdnf with args "remove dnf-ci-kernel"
   Then the exit code is 1
    And stderr is
        """
        Failed to resolve the transaction:
        Problem: The operation would result in removing of running kernel: dnf-ci-kernel-0:1.0-1.x86_64
        """


@bz1698145
Scenario: Running kernel is protected against obsoleting
   When I execute microdnf with args "install dnf-ci-obsolete"
   Then the exit code is 1
    And stderr is
        """
        <REPOSYNC>
        Failed to resolve the transaction:
        Problem: The operation would result in removing of running kernel: dnf-ci-kernel-0:1.0-1.x86_64
        You can try to add to command line:
          --skip-broken to skip uninstallable packages
        """


@bz1855542
@bz1698145
Scenario: Running kernel is not protected against obsoleting with config protect_running_kernel=False
  Given I configure dnf with
        | key                       | value            |
        | protect_running_kernel    | 0                |
   When I execute microdnf with args "install dnf-ci-obsolete"
   Then the exit code is 0
    And transaction is following
        | Action        | Package                             |
        | install       | dnf-ci-obsolete-0:1.0-1.x86_64      |
        | obsoleted     | dnf-ci-kernel-0:1.0-1.x86_64        |
