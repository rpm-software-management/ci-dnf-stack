Feature: Installroot test


@force_installroot
Scenario: Install package from host repository into empty installroot
  Given I use the repository "dnf-ci-install-remove"
   When I execute dnf with args "install water_carbonated"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | water_carbonated-0:1.0-1.x86_64   |
   When I execute rpm on host with args "-q water_carbonated"
   Then the exit code is 1


@force_installroot
Scenario: Install package from installroot repository into installroot
  Given I use the repository "dnf-ci-install-remove"
    And I create and substitute file "/etc/yum.repos.d/insideinstallroot.repo" with
    """
    [dnf-ci-install-remove]
    name=dnf-ci-install-remove
    baseurl=$DNF0/repos/dnf-ci-install-remove
    enabled=1
    gpgcheck=0
    """
    And I do not set reposdir
   When I execute dnf with args "install water_carbonated"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | water_carbonated-0:1.0-1.x86_64   |
   When I execute rpm on host with args "-q water_carbonated"
   Then the exit code is 1


@force_installroot
Scenario: Test metadata handling in installroot
  Given I use the repository "dnf-ci-install-remove"
    And I create and substitute file "/etc/yum.repos.d/insideinstallroot.repo" with
    """
    [dnf-ci-install-remove]
    name=dnf-ci-install-remove
    baseurl=$DNF0/repos/dnf-ci-install-remove
    enabled=1
    gpgcheck=0
    """
    And I do not set reposdir
   When I execute dnf with args "install water_carbonated"
   Then the exit code is 0
   When I execute bash with args "rm -rf {context.dnf.installroot}/var/cache/dnf" in directory "{context.dnf.installroot}"
   Then the exit code is 0
   When I execute dnf with args "install -C water_still"
   Then the exit code is 1
   When I execute dnf with args "makecache"
   Then the exit code is 0
   When I execute dnf with args "install -C water_still"
   Then the exit code is 1
   When I execute dnf with args "install --downloadonly water_still"
   Then the exit code is 0
   When I execute dnf with args "install -C water_still"
   Then the exit code is 0


@force_installroot
Scenario: Remove package from installroot
  Given I use the repository "dnf-ci-install-remove"
   When I execute dnf with args "install water_carbonated tea"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | water_carbonated-0:1.0-1.x86_64   |
        | install       | tea-0:1.0-1.x86_64                |
        | install       | water-0:1.0-1.x86_64              |
   When I execute dnf with args "remove water_carbonated"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | water_carbonated-0:1.0-1.x86_64   |


@force_installroot
Scenario: Repolist command in installroot
  Given I do not disable all repos
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "dnf-ci-install-remove"
  Given I create and substitute file "/etc/yum.repos.d/insideinstallroot.repo" with
    """
    [dnf-ci-fedora]
    name=dnf-ci-fedora
    baseurl=$DNF0/repos/dnf-ci-fedora
    enabled=1
    gpgcheck=0
    """
    And I do not set reposdir
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout does not contain "dnf-ci-install-remove"
    And stdout contains "dnf-ci-fedora"


@force_installroot
Scenario: Upgrade package in installroot
  Given I use the repository "dnf-ci-install-remove"
   When I execute dnf with args "install sugar-1.0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | sugar-0:1.0-1.x86_64              |
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | upgrade       | sugar-0:2.0-1.x86_64              |
   When I execute rpm on host with args "-q sugar"
   Then the exit code is 1
