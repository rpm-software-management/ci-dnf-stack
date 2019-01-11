Feature: Upgrade all RPMs


Background: Install some RPMs from one repository
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install glibc flac wget"
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


Scenario: Upgrade all RPMs from one repository
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
        | upgrade       | flac-0:1.3.3-2.fc29.x86_64                |
        | upgrade       | wget-0:1.19.6-5.fc29.x86_64               |


Scenario: Upgrade all RPMs from one repository using '*'
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade '*'"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
        | upgrade       | flac-0:1.3.3-2.fc29.x86_64                |
        | upgrade       | wget-0:1.19.6-5.fc29.x86_64               |
