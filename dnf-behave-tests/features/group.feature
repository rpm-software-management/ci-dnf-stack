Feature: Testing groups

# DNF-CI-Testgroup structure:
#   mandatory: filesystem (requires setup)
#   default: lame (requires lame-libs)
#   optional: flac
#   conditional: wget, requires filesystem-content

Scenario: Install and remove group
  Given I use the repository "dnf-ci-thirdparty"
    And I use the repository "dnf-ci-fedora"
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
  Given I use the repository "dnf-ci-thirdparty"
    And I use the repository "dnf-ci-fedora"
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


Scenario: Install and remove group with excluded package dependency
  Given I use the repository "dnf-ci-thirdparty"
    And I use the repository "dnf-ci-fedora"
   When I execute dnf with args "group install --exclude=setup DNF-CI-Testgroup"
   Then the exit code is 1
    And stderr contains "Problem: package filesystem-3.9-2.fc29.x86_64 requires setup, but none of the providers can be installed"


Scenario: Install condidional package if required package is about to be installed
  Given I use the repository "dnf-ci-thirdparty"
    And I use the repository "dnf-ci-fedora"
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


Scenario: Install condidional package if required package has been installed
  Given I use the repository "dnf-ci-thirdparty"
    And I use the repository "dnf-ci-fedora"
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
