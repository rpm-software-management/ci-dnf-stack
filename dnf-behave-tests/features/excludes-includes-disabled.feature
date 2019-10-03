Feature: Test config options includepkgs and excludepkgs with option --disableexcludes


Scenario Outline: Install an RPM that is NOT in includepkgs in <conf>, with option --disableexcludepkgs equal to <disable-conf>
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install flac --setopt=<prefix>includepkgs=setup --disableexcludepkgs=<disable-conf>"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                          |
        | install       | flac-0:1.3.2-8.fc29.x86_64       |

Examples:
  | conf   | prefix         | disable-conf   |
  | main   |                | main           |
  | main   |                | all            |
  | repo   | dnf-ci-fedora. | dnf-ci-fedora  |
  | repo   | dnf-ci-fedora. | all            |


Scenario Outline: Install an RPM that is in excludepkgs in <conf>, with option --disableexcludepkgs equal to <disable-conf>
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install flac --setopt=<prefix>excludepkgs=flac --disableexcludepkgs=<disable-conf>"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                          |
        | install       | flac-0:1.3.2-8.fc29.x86_64       |

Examples:
  | conf   | prefix         | disable-conf   |
  | main   |                | main           |
  | main   |                | all            |
  | repo   | dnf-ci-fedora. | dnf-ci-fedora  |
  | repo   | dnf-ci-fedora. | all            |


Scenario: Fail to install an RPM that is NOT in includepkgs in main conf, with option --disableexcludepkgs equal to <repo-id>
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install flac --setopt=includepkgs=setup --disableexcludepkgs=dnf-ci-fedora"
   Then the exit code is 1
    And Transaction is empty


Scenario: Fail to install an RPM that is in excludepkgs in main conf, with option --disableexcludepkgs equal to <repo-id>
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install flac --setopt=excludepkgs=flac --disableexcludepkgs=dnf-ci-fedora"
   Then the exit code is 1
    And Transaction is empty


Scenario: Fail to install an RPM that is NOT in includepkgs in repo conf, with option --disableexcludepkgs equal to main
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install flac --setopt=dnf-ci-fedora.includepkgs=setup --disableexcludepkgs=main"
   Then the exit code is 1
    And Transaction is empty


Scenario: Fail to install an RPM that is in excludepkgs in repo conf, with option --disableexcludepkgs equal to main
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install flac --setopt=dnf-ci-fedora.excludepkgs=flac --disableexcludepkgs=main"
   Then the exit code is 1
    And Transaction is empty
