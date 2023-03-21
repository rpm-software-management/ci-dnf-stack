@dnf5
Feature: Protect running kernel


Background: Install fake kernel
  Given I use repository "protect-running-kernel"
    And I successfully execute dnf with args "install dnf-ci-kernel --exclude dnf-ci-obsolete"
    And I fake kernel release to "1.0"


@bz1698145
Scenario: Running kernel is protected
   When I execute dnf with args "remove dnf-ci-kernel"
   Then the exit code is 1
    And stderr is
        """
        Failed to resolve the transaction:
        Problem: The operation would result in removing of running kernel: dnf-ci-kernel-0:1.0-1.x86_64
        """


@bz1698145
Scenario: Running kernel is not protected with config protect_running_kernel=False
   When I execute dnf with args "remove dnf-ci-kernel --setopt=protect_running_kernel=False"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                             |
        | remove        | dnf-ci-kernel-0:1.0-1.x86_64        |
        | remove-unused | dnf-ci-systemd-0:1.0-1.x86_64       |


@bz1698145
Scenario: Running kernel is protected when in protected_packages even with config protect_running_kernel=False
   When I execute dnf with args "remove dnf-ci-kernel --setopt=protect_running_kernel=False --setopt=protected_packages=dnf-ci-kernel"
   Then the exit code is 1
    And stderr is
        """
        Failed to resolve the transaction:
        Problem: The operation would result in removing the following protected packages: dnf-ci-kernel
        """


@bz1698145
Scenario: Running kernel is protected against obsoleting
   When I execute dnf with args "install dnf-ci-obsolete"
   Then the exit code is 1
    And stderr is
        """
        Failed to resolve the transaction:
        Problem: The operation would result in removing of running kernel: dnf-ci-kernel-0:1.0-1.x86_64
        """


@bz1698145
Scenario: Running kernel is not protected against obsoleting with config protect_running_kernel=False
   When I execute dnf with args "install dnf-ci-obsolete --setopt=protect_running_kernel=False"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                             |
        | install       | dnf-ci-obsolete-0:1.0-1.x86_64      |
        | obsoleted     | dnf-ci-kernel-0:1.0-1.x86_64        |


@bz1698145
Scenario: Running kernel is protected against removal as conflict
   When I execute dnf with args "install dnf-ci-conflict --exclude dnf-ci-obsolete --allowerasing"
   Then the exit code is 1
    And stderr is
        """
        Failed to resolve the transaction:
        Problem: problem with installed package 
          - package dnf-ci-conflict-1.0-1.x86_64 conflicts with dnf-ci-kernel = 1.0-1 provided by dnf-ci-kernel-1.0-1.x86_64
          - conflicting requests
        """

@bz1698145
Scenario: Running kernel is not protected against removal as conflict with config protect_running_kernel=False
   When I execute dnf with args "install dnf-ci-conflict --exclude dnf-ci-obsolete --allowerasing --setopt=protect_running_kernel=False"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                             |
        | install       | dnf-ci-conflict-0:1.0-1.x86_64      |
        | remove-dep    | dnf-ci-kernel-0:1.0-1.x86_64        |
