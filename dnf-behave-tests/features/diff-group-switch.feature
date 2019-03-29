Feature: Test for swap command


Background: Enable repositories
  Given I use the repository "dnf-ci-fedora"
  Given I use the repository "dnf-ci-fedora-updates"
  Given I use the repository "dnf-ci-thirdparty"
   When I execute dnf with args "groupinstall CQRlib-non-devel"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | CQRlib-0:1.1.2-16.fc29.x86_64             |
        | install       | CQRlib-extension-0:1.5-2.x86_64           |
        | group-install | CQRlib-non-devel                          |
   When I execute dnf with args "install CQRlib-devel"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |


Scenario: Switch groups by swap command
   When I execute dnf with args "swap @CQRlib-non-devel @SuperRipper-and-deps"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | CQRlib-extension-0:1.5-2.x86_64           |
        | install       | SuperRipper-extension-0:1.1-1.x86_64      |
        | install       | SuperRipper-0:1.0-1.x86_64                |
        | install       | abcde-0:2.9.3-1.fc29.noarch               |
        | install       | flac-0:1.3.3-3.fc29.x86_64                |
        | install       | wget-0:1.19.6-5.fc29.x86_64               |
        | install       | FlacBetterEncoder-0:1.0-1.x86_64          |
        | unchanged     | CQRlib-0:1.1.2-16.fc29.x86_64             |
        | group-remove  | CQRlib-non-devel                          |
        | group-install | SuperRipper-and-deps                      |


Scenario: Switch groups by remove and install
   When I execute dnf with args "remove @CQRlib-non-devel"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | unchanged     | CQRlib-0:1.1.2-16.fc29.x86_64             |
        | remove        | CQRlib-extension-0:1.5-2.x86_64           |
        | group-remove  | CQRlib-non-devel                          |
   When I execute dnf with args "install @SuperRipper-and-deps"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | SuperRipper-extension-0:1.1-1.x86_64      |
        | install       | SuperRipper-0:1.0-1.x86_64                |
        | install       | abcde-0:2.9.3-1.fc29.noarch               |
        | install       | flac-0:1.3.3-3.fc29.x86_64                |
        | install       | wget-0:1.19.6-5.fc29.x86_64               |
        | install       | FlacBetterEncoder-0:1.0-1.x86_64          |
        | group-install | SuperRipper-and-deps                      |


Scenario: Switch groups by shell remove and install
   When I open dnf shell session
    And I execute in dnf shell "remove @CQRlib-non-devel"
    And I execute in dnf shell "install @SuperRipper-and-deps"
    And I execute in dnf shell "run"
   Then Transaction is following
        | Action        | Package                                   |
        | remove        | CQRlib-extension-0:1.5-2.x86_64           |
        | install       | SuperRipper-0:1.0-1.x86_64                |
        | install       | SuperRipper-extension-0:1.1-1.x86_64      |
        | install       | abcde-0:2.9.3-1.fc29.noarch               |
        | install       | flac-0:1.3.3-3.fc29.x86_64                |
        | install       | wget-0:1.19.6-5.fc29.x86_64               |
        | install       | FlacBetterEncoder-0:1.0-1.x86_64          |
        | unchanged     | CQRlib-0:1.1.2-16.fc29.x86_64             |
        | group-remove  | CQRlib-non-devel                          |
        | group-install | SuperRipper-and-deps                      |
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"
