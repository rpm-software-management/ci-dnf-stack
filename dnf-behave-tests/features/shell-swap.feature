Feature: Shell swap


Scenario: Switch packages and their subpackages by swap command (using wildcards)
 When I open dnf shell session
  And I execute in dnf shell "repo enable dnf-ci-fedora"
  And I execute in dnf shell "repo enable dnf-ci-fedora-updates"
  And I execute in dnf shell "repo enable dnf-ci-thirdparty"
  And I execute in dnf shell "install CQRlib-devel CQRlib CQRlib-extension"
  And I execute in dnf shell "run"
 Then Transaction is following
      | Action        | Package                                   |
      | install       | CQRlib-0:1.1.2-16.fc29.x86_64             |
      | install       | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |
      | install       | CQRlib-extension-0:1.5-2.x86_64           |
  And I execute in dnf shell "swap CQRlib\* SuperRipper\*"
  And I execute in dnf shell "run"
  And Transaction is following
      | Action        | Package                                   |
      | remove        | CQRlib-0:1.1.2-16.fc29.x86_64             |
      | remove        | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |
      | remove        | CQRlib-extension-0:1.5-2.x86_64           |
      | install       | SuperRipper-extension-0:1.1-1.x86_64      |
      | install       | SuperRipper-0:1.0-1.x86_64                |
      | install       | abcde-0:2.9.3-1.fc29.noarch               |
      | install       | flac-0:1.3.3-3.fc29.x86_64                |
      | install       | wget-0:1.19.6-5.fc29.x86_64               |
      | install       | FlacBetterEncoder-0:1.0-1.x86_64          |
  And I execute in dnf shell "install CQRlib-devel"
  And I execute in dnf shell "run"
  And Transaction is following
      | Action        | Package                                   |
      | install       | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |
 When I execute in dnf shell "exit"
 Then stdout contains "Leaving Shell"


@not.with_os=rhel__eq__8
Scenario: Switch groups by swap command
 When I open dnf shell session
  And I execute in dnf shell "repo enable dnf-ci-fedora"
  And I execute in dnf shell "repo enable dnf-ci-fedora-updates"
  And I execute in dnf shell "repo enable dnf-ci-thirdparty"
  And I execute in dnf shell "groupinstall CQRlib-non-devel"
  And I execute in dnf shell "run"
 Then Transaction is following
      | Action        | Package                                   |
      | install       | CQRlib-0:1.1.2-16.fc29.x86_64             |
      | install       | CQRlib-extension-0:1.5-2.x86_64           |
      | group-install | CQRlib-non-devel                          |
  And I execute in dnf shell "install CQRlib-devel"
  And I execute in dnf shell "run"
  And Transaction is following
      | Action        | Package                                   |
      | install       | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |
  And I execute in dnf shell "swap @CQRlib-non-devel @SuperRipper-and-deps"
  And I execute in dnf shell "run"
  And Transaction is following
      | Action        | Package                                   |
      | remove        | CQRlib-extension-0:1.5-2.x86_64           |
      | install       | SuperRipper-extension-0:1.1-1.x86_64      |
      | install       | SuperRipper-0:1.0-1.x86_64                |
      | install       | abcde-0:2.9.3-1.fc29.noarch               |
      | install       | flac-0:1.3.3-3.fc29.x86_64                |
      | install       | wget-0:1.19.6-5.fc29.x86_64               |
      | install       | FlacBetterEncoder-0:1.0-1.x86_64          |
      | group-remove  | CQRlib-non-devel                          |
      | group-install | SuperRipper-and-deps                      |
