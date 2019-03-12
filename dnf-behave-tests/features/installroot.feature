Feature: Installroot test


@force_tmp_installroot
Scenario: Install package from host repository into empty installroot
  Given I use the repository "dnf-ci-install-remove"
   When I execute dnf with args "install water_carbonated"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | water_carbonated-0:1.0-1.x86_64   |
   When I execute rpm on host with args "-q water_carbonated"
   Then the exit code is 1


@force_tmp_installroot
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


@force_tmp_installroot
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
   When I execute dnf with args "remove water_still"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | water_still-0:1.0-1.x86_64        |
