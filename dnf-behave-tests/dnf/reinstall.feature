@dnf5
Feature: Reinstall


Background: Install CQRlib-devel and CQRlib
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install CQRlib-devel"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |
        | install-dep   | CQRlib-0:1.1.2-16.fc29.x86_64             |


Scenario: Reinstall an RPM from the same repository
   When I execute dnf with args "reinstall CQRlib"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | reinstall     | CQRlib-0:1.1.2-16.fc29.x86_64             |
    And package state is
        | package                           | reason     | from_repo             |
        | CQRlib-devel-1.1.2-16.fc29.x86_64 | User       | dnf-ci-fedora         |
        | CQRlib-1.1.2-16.fc29.x86_64       | Dependency | dnf-ci-fedora-updates |


Scenario: Reinstall an RPM from different repository
  Given I use repository "dnf-ci-fedora-updates-testing"
    And I drop repository "dnf-ci-fedora-updates"
   When I execute dnf with args "reinstall CQRlib"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | reinstall     | CQRlib-0:1.1.2-16.fc29.x86_64             |
    And package state is
        | package                           | reason     | from_repo                     |
        | CQRlib-devel-1.1.2-16.fc29.x86_64 | User       | dnf-ci-fedora                 |
        | CQRlib-1.1.2-16.fc29.x86_64       | Dependency | dnf-ci-fedora-updates-testing |


Scenario: Reinstall an RPM that is not available
  Given I drop repository "dnf-ci-fedora-updates"
   When I execute dnf with args "reinstall CQRlib"
   Then the exit code is 1
