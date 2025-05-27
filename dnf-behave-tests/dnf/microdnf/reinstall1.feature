Feature: Reinstall


Background: Install CQRlib-devel and CQRlib
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"
   When I execute microdnf with args "install CQRlib-devel"
   Then the exit code is 0
    And RPMDB Transaction is following
        | Action        | Package                                   |
        | install       | CQRlib-0:1.1.2-16.fc29.x86_64             |
        | install       | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |


Scenario: Reinstall an RPM from the same repository
   When I execute microdnf with args "reinstall CQRlib"
   Then the exit code is 0
    And RPMDB Transaction is following
        | Action        | Package                                   |
        | reinstall     | CQRlib-0:1.1.2-16.fc29.x86_64             |
