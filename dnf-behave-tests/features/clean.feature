Feature: Testing dnf clean command


Scenario: Ensure that metadata are unavailable after "dnf clean all"
  Given I use the repository "dnf-ci-rich"
   When I execute dnf with args "makecache"
   Then the exit code is 0
   When I execute dnf with args "install -C cream"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | cream-0:1.0-1.x86_64                  |
   When I execute dnf with args "clean all"
   Then the exit code is 0
   When I execute dnf with args "install -C dill"
   Then the exit code is 1
    And stdout contains "No match for argument: dill"
   When I execute dnf with args "remove cream"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | remove        | cream-0:1.0-1.x86_64                  |


@tier1
Scenario: Expire dnf cache and run repoquery for a package that has been removed meanwhile
  # use temporary copy of repository dnf-ci-thirdparty-updates for this test
  Given I copy directory "{context.dnf.repos_location}/dnf-ci-thirdparty-updates" to "/temp-repos/temp-repo"
    And I create and substitute file "/etc/yum.repos.d/test.repo" with
    """
    [testrepo]
    name=testrepo
    baseurl={context.dnf.installroot}/temp-repos/temp-repo
    enabled=1
    gpgcheck=0
    """
    And I do not set reposdir
    And I use the repository "testrepo"
   When I execute dnf with args "repoquery --available SuperRipper"
   Then the exit code is 0
    And stdout contains "SuperRipper-0:1.2-1.x86_64"
  Given I delete file "/temp-repos/temp-repo/x86_64/SuperRipper-1.2-1.x86_64.rpm"
    And I execute "createrepo_c --update ." in "{context.dnf.installroot}/temp-repos/temp-repo"
   When I execute dnf with args "repoquery --available SuperRipper"
   Then the exit code is 0
    And stdout contains "SuperRipper-0:1.2-1.x86_64"
   When I execute dnf with args "clean expire-cache"
   Then the exit code is 0
   When I execute dnf with args "repoquery --available SuperRipper"
   Then the exit code is 0
    And stdout does not contain "SuperRipper-0:1.2-1.x86_64"


@tier1
Scenario: Expire dnf cache and run repolist when a package has been removed meanwhile
  # use temporary copy of repository dnf-ci-thirdparty-updates for this test
  Given I copy directory "{context.dnf.repos_location}/dnf-ci-thirdparty-updates" to "/temp-repos/temp-repo"
    And I create and substitute file "/etc/yum.repos.d/test.repo" with
    """
    [testrepo]
    name=testrepo
    baseurl={context.dnf.installroot}/temp-repos/temp-repo
    enabled=1
    gpgcheck=0
    """
    And I do not set reposdir
    And I use the repository "testrepo"
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "testrepo\s+testrepo\s+6"
  Given I delete file "/temp-repos/temp-repo/x86_64/SuperRipper-1.2-1.x86_64.rpm"
    And I execute "createrepo_c --update ." in "{context.dnf.installroot}/temp-repos/temp-repo"
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "testrepo\s+testrepo\s+6"
   When I execute dnf with args "clean expire-cache"
   Then the exit code is 0
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "testrepo\s+testrepo\s+5"

