Feature: Upgrade single RPMs


Background: Install RPMs
  Given I use the repository "dnf-ci-fedora"
    And I use the repository "dnf-ci-thirdparty"
   When I execute dnf with args "install glibc flac wget SuperRipper"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install       | glibc-common-0:2.28-9.fc29.x86_64         |
        | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
        | install       | flac-0:1.3.2-8.fc29.x86_64                |
        | install       | wget-0:1.19.5-5.fc29.x86_64               |
        | install       | SuperRipper-0:1.0-1.x86_64                |
        | install       | abcde-0:2.9.2-1.fc29.noarch               |
        | install       | FlacBetterEncoder-0:1.0-1.x86_64          |


@tier1
Scenario: Upgrade one RPM
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |


Scenario: Upgrade two RPMs
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade glibc flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
        | upgrade       | flac-0:1.3.3-3.fc29.x86_64                |
