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
        | install       | setup-0:2.12.1-1.fc29.noarch      |
        | install       | filesystem-0:3.9-2.fc29.x86_64    |
        | install       | lame-0:3.100-4.fc29.x86_64        |
        | install       | lame-libs-0:3.100-4.fc29.x86_64   |
        | group-install | DNF-CI-Testgroup                  |
   When I execute dnf with args "group remove DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | setup-0:2.12.1-1.fc29.noarch      |
        | remove        | filesystem-0:3.9-2.fc29.x86_64    |
        | remove        | lame-0:3.100-4.fc29.x86_64        |
        | remove        | lame-libs-0:3.100-4.fc29.x86_64   |
        | group-remove  | DNF-CI-Testgroup                  |


Scenario: Install and remove group with excluded package
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "group install --exclude=lame DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | setup-0:2.12.1-1.fc29.noarch      |
        | install       | filesystem-0:3.9-2.fc29.x86_64    |
        | group-install | DNF-CI-Testgroup                  |
   When I execute dnf with args "group remove DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | setup-0:2.12.1-1.fc29.noarch      |
        | remove        | filesystem-0:3.9-2.fc29.x86_64    |
        | group-remove  | DNF-CI-Testgroup                  |

@bz1707624
Scenario: Install installed group when group is not available
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "group install --exclude=lame DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | setup-0:2.12.1-1.fc29.noarch      |
        | install       | filesystem-0:3.9-2.fc29.x86_64    |
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
    And stderr contains "Problem: package filesystem-3.9-2.fc29.x86_64 requires setup, but none of the providers can be installed"


@xfail
@bz1673851
Scenario: Install condidional package if required package is about to be installed
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "install @DNF-CI-Testgroup filesystem-content"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | lame-0:3.100-4.fc29.x86_64                |
        | install       | lame-libs-0:3.100-4.fc29.x86_64           |
        | install       | filesystem-content-0:3.9-2.fc29.x86_64    |
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
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | lame-0:3.100-4.fc29.x86_64                |
        | install       | lame-libs-0:3.100-4.fc29.x86_64           |
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
        | remove        | lame-libs-0:3.100-4.fc29.x86_64           |
        | group-remove  | DNF-CI-Testgroup                          |
        | unchanged     | filesystem-0:3.9-2.fc29.x86_64            |
        | unchanged     | setup-0:2.12.1-1.fc29.noarch              |
   When I execute dnf with args "remove basesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | basesystem-0:11-6.fc29.noarch             |
        | remove        | filesystem-0:3.9-2.fc29.x86_64            |
        | remove        | setup-0:2.12.1-1.fc29.noarch              |


Scenario: Group remove does not remove user installed packages
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
   When I execute dnf with args "group install DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | lame-0:3.100-4.fc29.x86_64                |
        | install       | lame-libs-0:3.100-4.fc29.x86_64           |
        | group-install | DNF-CI-Testgroup                          |
        # filesystem package should be kept because they are user installed
   When I execute dnf with args "group remove DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | lame-0:3.100-4.fc29.x86_64                |
        | remove        | lame-libs-0:3.100-4.fc29.x86_64           |
        | group-remove  | DNF-CI-Testgroup                          |
        | unchanged     | filesystem-0:3.9-2.fc29.x86_64            |
        | unchanged     | setup-0:2.12.1-1.fc29.noarch              |

@not.with_os=rhel__eq__8
@bz1809600
Scenario: Group remove does not traceback when reason change
  Given I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora"
   When I execute dnf with args "group install DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | lame-0:3.100-4.fc29.x86_64                |
        | install       | lame-libs-0:3.100-4.fc29.x86_64           |
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
        | remove        | lame-libs-0:3.100-4.fc29.x86_64           |
        | group-remove  | DNF-CI-Testgroup                          |
        | remove        | filesystem-0:3.9-2.fc29.x86_64            |
        | remove        | setup-0:2.12.1-1.fc29.noarch              |
        | remove        | basesystem-0:11-6.fc29.noarch             |
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
