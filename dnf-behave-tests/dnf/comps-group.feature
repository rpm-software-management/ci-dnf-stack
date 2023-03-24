Feature: Testing groups

# DNF-CI-Testgroup structure:
#   mandatory: filesystem (requires setup)
#   default: lame (requires lame-libs)
#   optional: flac
#   conditional: wget, requires filesystem-content

Scenario: Install and remove group
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "group install DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install-group | filesystem-0:3.9-2.fc29.x86_64    |
        | install-group | lame-0:3.100-4.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch      |
        | install-dep   | lame-libs-0:3.100-4.fc29.x86_64   |
        | group-install | DNF-CI-Testgroup                  |
   When I execute dnf with args "group remove DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | filesystem-0:3.9-2.fc29.x86_64    |
        | remove        | lame-0:3.100-4.fc29.x86_64        |
        | remove-unused | setup-0:2.12.1-1.fc29.noarch      |
        | remove-unused | lame-libs-0:3.100-4.fc29.x86_64   |
        | group-remove  | DNF-CI-Testgroup                  |


Scenario: Install a group that is already installed
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "group install DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install-group | filesystem-0:3.9-2.fc29.x86_64    |
        | install-group | lame-0:3.100-4.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch      |
        | install-dep   | lame-libs-0:3.100-4.fc29.x86_64   |
        | group-install | DNF-CI-Testgroup                  |
   When I execute dnf with args "group install DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | group-install | DNF-CI-Testgroup                  |


Scenario: Install and remove group with excluded package
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "group install --exclude=lame DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install-group | filesystem-0:3.9-2.fc29.x86_64    |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch      |
        | group-install | DNF-CI-Testgroup                  |
   When I execute dnf with args "group remove DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | filesystem-0:3.9-2.fc29.x86_64    |
        | remove-unused | setup-0:2.12.1-1.fc29.noarch      |
        | group-remove  | DNF-CI-Testgroup                  |

@bz1707624
Scenario: Install installed group when group is not available
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "group install --exclude=lame DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install-group | filesystem-0:3.9-2.fc29.x86_64    |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch      |
        | group-install | DNF-CI-Testgroup                  |
   When I execute dnf with args "group install --disablerepo=dnf-ci-thirdparty DNF-CI-Testgroup"
   Then the exit code is 1
    And stderr contains "Module or Group 'DNF-CI-Testgroup' is not available."
    And stderr does not contain "ValueError"

Scenario: Install and remove group with excluded package dependency
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "group install --exclude=setup DNF-CI-Testgroup"
   Then the exit code is 1
    And stderr contains "Problem: package filesystem-3.9-2.fc29.x86_64 from dnf-ci-fedora requires setup, but none of the providers can be installed"


@xfail
@bz1673851
Scenario: Install condidional package if required package is about to be installed
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "install @DNF-CI-Testgroup filesystem-content"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | filesystem-content-0:3.9-2.fc29.x86_64    |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | lame-0:3.100-4.fc29.x86_64                |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | lame-libs-0:3.100-4.fc29.x86_64           |
        | install       | wget-0:1.19.5-5.fc29.x86_64               |
        | group-install | DNF-CI-Testgroup                          |
   When I execute dnf with args "group remove DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | setup-0:2.12.1-1.fc29.noarch              |
        | remove        | filesystem-0:3.9-2.fc29.x86_64            |
        | remove        | lame-0:3.100-4.fc29.x86_64                |
        | remove        | lame-libs-0:3.100-4.fc29.x86_64           |
        | remove        | wget-0:1.19.5-5.fc29.x86_64               |
        | group-remove  | DNF-CI-Testgroup                          |


@xfail
@bz1673851
Scenario: Install condidional package if required package has been installed
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "install filesystem-content"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | filesystem-content-0:3.9-2.fc29.x86_64    |
   When I execute dnf with args "group install DNF-CI-Testgroup "
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | lame-0:3.100-4.fc29.x86_64                |
        | install       | lame-libs-0:3.100-4.fc29.x86_64           |
        | install       | wget-0:1.19.5-5.fc29.x86_64               |
        | group-install | DNF-CI-Testgroup                          |


# basesystem requires filesystem (part of DNF-CI-Testgroup)
Scenario: Group remove does not remove packages required by user installed packages
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "group install DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install-group | filesystem-0:3.9-2.fc29.x86_64            |
        | install-group | lame-0:3.100-4.fc29.x86_64                |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
        | install-dep   | lame-libs-0:3.100-4.fc29.x86_64           |
        | group-install | DNF-CI-Testgroup                          |
   When I execute dnf with args "install basesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | basesystem-0:11-6.fc29.noarch             |
        # setup and filesystem packages should be kept because they are required by
        # userinstalled basesystem
   When I execute dnf with args "group remove DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | lame-0:3.100-4.fc29.x86_64                |
        | remove-unused | lame-libs-0:3.100-4.fc29.x86_64           |
        | group-remove  | DNF-CI-Testgroup                          |
        | unchanged     | filesystem-0:3.9-2.fc29.x86_64            |
        | unchanged     | setup-0:2.12.1-1.fc29.noarch              |
   When I execute dnf with args "remove basesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | basesystem-0:11-6.fc29.noarch             |
        | remove-unused | filesystem-0:3.9-2.fc29.x86_64            |
        | remove-unused | setup-0:2.12.1-1.fc29.noarch              |


Scenario: Group remove does not remove user installed packages
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
   When I execute dnf with args "group install DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install-group | lame-0:3.100-4.fc29.x86_64                |
        | install-dep   | lame-libs-0:3.100-4.fc29.x86_64           |
        | group-install | DNF-CI-Testgroup                          |
        # filesystem package should be kept because they are user installed
   When I execute dnf with args "group remove DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | lame-0:3.100-4.fc29.x86_64                |
        | remove-unused | lame-libs-0:3.100-4.fc29.x86_64           |
        | group-remove  | DNF-CI-Testgroup                          |
        | unchanged     | filesystem-0:3.9-2.fc29.x86_64            |
        | unchanged     | setup-0:2.12.1-1.fc29.noarch              |

@bz1809600
Scenario: Group remove does not traceback when reason change
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "group install DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install-group | filesystem-0:3.9-2.fc29.x86_64            |
        | install-group | lame-0:3.100-4.fc29.x86_64                |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
        | install-dep   | lame-libs-0:3.100-4.fc29.x86_64           |
        | group-install | DNF-CI-Testgroup                          |
   When I execute dnf with args "install basesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | basesystem-0:11-6.fc29.noarch             |
        # filesystem package should be removed without Tracebacks in callbacks
  When I open dnf shell session
    And I execute in dnf shell "group remove DNF-CI-Testgroup"
    And I execute in dnf shell "remove filesystem"
    And I execute in dnf shell "run"
   Then Transaction is following
        | Action        | Package                                   |
        | remove        | lame-0:3.100-4.fc29.x86_64                |
        | remove        | filesystem-0:3.9-2.fc29.x86_64            |
        | remove-dep    | basesystem-0:11-6.fc29.noarch             |
        | remove-unused | setup-0:2.12.1-1.fc29.noarch              |
        | remove-unused | lame-libs-0:3.100-4.fc29.x86_64           |
        | group-remove  | DNF-CI-Testgroup                          |
    And stdout does not contain "Traceback .*"
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"

@bz1706382
Scenario: Group list
 Given I use repository "dnf-ci-thirdparty"
  When I execute dnf with args "group list"
  Then the exit code is 0
   And stdout is
    """
    <REPOSYNC>
    Available Groups:
       DNF-CI-Testgroup
       CQRlib-non-devel
       SuperRipper-and-deps
    """

@bz1706382
Scenario: Group list --ids
 Given I use repository "dnf-ci-thirdparty"
  When I execute dnf with args "group list --ids"
  Then the exit code is 0
   And stdout is
    """
    <REPOSYNC>
    Available Groups:
       DNF-CI-Testgroup (dnf-ci-testgroup)
       CQRlib-non-devel (cqrlib-non-devel)
       SuperRipper-and-deps (superripper-and-deps)
    """

@bz1706382
Scenario: Group list --ids with arg
 Given I use repository "dnf-ci-thirdparty"
  When I execute dnf with args "group list --ids dnf-ci-testgroup"
  Then the exit code is 0
   And stdout is
    """
    <REPOSYNC>
    Available Groups:
       DNF-CI-Testgroup (dnf-ci-testgroup)
    """

@bz1706382
Scenario: Group list ids => yum compatibility
 Given I use repository "dnf-ci-thirdparty"
  When I execute dnf with args "group list ids"
  Then the exit code is 0
   And stdout is
    """
    <REPOSYNC>
    Available Groups:
       DNF-CI-Testgroup (dnf-ci-testgroup)
       CQRlib-non-devel (cqrlib-non-devel)
       SuperRipper-and-deps (superripper-and-deps)
    """

@bz1706382
Scenario: Group list ids with arg => yum compatibility
 Given I use repository "dnf-ci-thirdparty"
  When I execute dnf with args "group list ids dnf-ci-testgroup"
  Then the exit code is 0
   And stdout is
    """
    <REPOSYNC>
    Available Groups:
       DNF-CI-Testgroup (dnf-ci-testgroup)
    """

@bz1826198
Scenario: List an environment with empty name
  Given I use repository "comps-group"
  When I execute dnf with args "group list"
   Then the exit code is 0
   And stdout is
       """
       <REPOSYNC>
       Available Environment Groups:
          <name-unset>
          Env with a nonexistent group
       Available Groups:
          Test Group
          <name-unset>
       """

@bz1826198
Scenario: Install a group with empty name
  Given I use repository "comps-group"
  When I execute dnf with args "group install no-name-group"
   Then the exit code is 0
    # note the group is not listed in the transaction due to its name missing
    And Transaction is following
        | Action        | Package                           |
        | group-install | <name-unset>                      |
        | install-group | test-package-1.0-1.fc29.noarch    |

@bz1826198
Scenario: Install an environment with empty name
  Given I use repository "comps-group"
  When I execute dnf with args "group install no-name-env"
   Then the exit code is 0
    # note the env group is not listed in the transaction due to its name missing
    And Transaction is following
        | Action        | Package                           |
        | env-install   | <name-unset>                      |
        | group-install | Test Group                        |
        | install-group | test-package-1.0-1.fc29.noarch    |


@not.with_os=rhel__ge__8
Scenario: List and info a group with missing packagelist
  Given I use repository "comps-group-merging"
   When I execute dnf with args "group list"
   Then the exit code is 0
    And stdout is
       """
       <REPOSYNC>
       Available Environment Groups:
          <name-unset>
       Available Groups:
          Test Group
       """
   When I execute dnf with args "group info test-group"
   Then stdout is
       """
       <REPOSYNC>
       Group: Test Group
        Description: Test Group description updated.
       """


Scenario: Install a group with empty packagelist
  Given I use repository "comps-group-merging"
   When I execute dnf with args "group install test-group"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package       |
        | group-install | Test Group    |


@not.with_os=rhel__ge__8
Scenario: Merge groups when one has empty packagelist
  Given I use repository "comps-group"
    And I use repository "comps-group-merging"
   When I execute dnf with args "group install test-group"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | group-install | Test Group                        |
        | install-group | test-package-1.0-1.fc29.noarch    |
   When I execute dnf with args "group info test-group"
   Then stdout is
       """
       <REPOSYNC>
       Group: Test Group
        Description: Test Group description updated.
        Mandatory Packages:
          test-package
       """


@not.with_os=rhel__ge__8
Scenario: Merge environment with missing names containg a group with missing name
  Given I use repository "comps-group"
    And I use repository "comps-group-merging"
   When I execute dnf with args "group info no-name-env"
   Then stdout is
       """
       <REPOSYNC>
       Environment Group: <name-unset>
        Mandatory Groups:
          <name-unset>
          Test Group
       """


@not.with_os=rhel__ge__8
Scenario: Group info with a group that has missing name
  Given I use repository "comps-group"
   When I execute dnf with args "group info no-name-group"
   Then stdout is
       """
       <REPOSYNC>
       Group: <name-unset>
        Mandatory Packages:
          test-package
       """


Scenario: Mark a group and an environment without name
  Given I use repository "comps-group"
    And I use repository "comps-group-merging"
   When I execute dnf with args "group mark no-name-group no-name-env"
   Then Transaction is following
        | Action        | Package                           |
        | env-install   | <name-unset>                      |
        | group-install | <name-unset>                      |
        | group-install | Test Group                        |


Scenario: Install an environment with a nonexistent group
  Given I use repository "comps-group"
  When I execute dnf with args "group install env-with-a-nonexistent-group"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | env-install   | Env with a nonexistent group      |
        | group-install | Test Group                        |
        | group-install | <name-unset>                      |
        | install-group | test-package-1.0-1.fc29.noarch    |
    And stderr is
       """
       no group 'nonexistent-group' from environment 'env-with-a-nonexistent-group'
       """
