Feature: Test for swap command


Background: Enable repositories
  Given I use repository "dnf-ci-fedora"
  Given I use repository "dnf-ci-fedora-updates"
  Given I use repository "dnf-ci-thirdparty"
    # "/usr" directory is needed to load rpm database (to overcome bad heuristics in libdnf created by Colin Walters)
    And I create directory "/usr"

Scenario: Switch packages by swap command
   When I execute microdnf with args "install CQRlib-devel CQRlib"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | install       | CQRlib-0:1.1.2-16.fc29.x86_64             |
        | install       | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |
   When I execute microdnf with args "swap CQRlib SuperRipper"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | remove        | CQRlib-0:1.1.2-16.fc29.x86_64             |
        | install       | SuperRipper-0:1.0-1.x86_64                |
        | install-dep   | abcde-0:2.9.3-1.fc29.noarch               |
        | install-dep   | wget-0:1.19.6-5.fc29.x86_64               |
        | install-weak  | FlacBetterEncoder-0:1.0-1.x86_64          |
        | install-weak  | flac-0:1.3.3-3.fc29.x86_64                |


Scenario: Switch packages and their subpackages by swap command with wildcards
   When I execute microdnf with args "install CQRlib-devel CQRlib CQRlib-extension"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | install       | CQRlib-0:1.1.2-16.fc29.x86_64             |
        | install       | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |
        | install       | CQRlib-extension-0:1.5-2.x86_64           |
   When I execute microdnf with args "swap CQRlib\* SuperRipper"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | remove        | CQRlib-0:1.1.2-16.fc29.x86_64             |
        | remove        | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |
        | remove        | CQRlib-extension-0:1.5-2.x86_64           |
        | install       | SuperRipper-0:1.0-1.x86_64                |
        | install-dep   | abcde-0:2.9.3-1.fc29.noarch               |
        | install-dep   | wget-0:1.19.6-5.fc29.x86_64               |
        | install-weak  | flac-0:1.3.3-3.fc29.x86_64                |
        | install-weak  | FlacBetterEncoder-0:1.0-1.x86_64          |
   When I execute microdnf with args "install CQRlib-devel"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | install       | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |
