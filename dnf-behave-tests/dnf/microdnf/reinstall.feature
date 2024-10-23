@dnf5
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


Scenario: Reinstall an RPM from different repository
  Given I use repository "dnf-ci-fedora-updates-testing"
   When I execute microdnf with args "reinstall CQRlib"
   Then the exit code is 0
    And RPMDB Transaction is following
        | Action        | Package                                   |
        | reinstall     | CQRlib-0:1.1.2-16.fc29.x86_64             |


Scenario: Reinstall an RPM that is not available
  Given I drop repository "dnf-ci-fedora-updates"
   When I execute microdnf with args "reinstall CQRlib"
   Then the exit code is 1
    And RPMDB Transaction is empty


Scenario: Try to reinstall a pkg if repo not available
  Given I use repository "simple-base"
    And I successfully execute microdnf with args "install labirinto"
   When I use repository "simple-base" with configuration
        | key     | value                               |
        | baseurl | https://www.not-available-repo.com/ |
   When I execute microdnf with args "reinstall labirinto"
   Then the exit code is 1
   And stderr contains "Failed to download metadata \(baseurl: \"https://www.not-available-repo.com/\"\) for repository \"simple-base\""


Scenario: Try to reinstall a pkg if repo not available
  Given I use repository "simple-base"
    And I successfully execute microdnf with args "install labirinto"
   When I configure a new repository "non-existent" with
        | key                 | value                               |
        | baseurl             | https://www.not-available-repo.com/ |
        | enabled             | 1                                   |
        | skip_if_unavailable | 0                                   |
   When I execute microdnf with args "reinstall labirinto"
   Then the exit code is 1
   And stderr contains "Failed to download metadata \(baseurl: \"https://www.not-available-repo.com/\"\) for repository \"non-existent\""
