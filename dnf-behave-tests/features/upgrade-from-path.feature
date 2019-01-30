Feature: Upgrade RPMs from path


Background: Install glibc
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install       | glibc-common-0:2.28-9.fc29.x86_64         |
        | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |


Scenario: Upgrade an RPM from absolute path on disk
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/glibc-2.28-26.fc29.x86_64.rpm"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |


Scenario: Upgrade an RPM from relative path on disk
   When I execute dnf with args "upgrade x86_64/glibc-2.28-26.fc29.x86_64.rpm x86_64/glibc-common-2.28-26.fc29.x86_64.rpm x86_64/glibc-all-langpacks-2.28-26.fc29.x86_64.rpm" from repo "dnf-ci-fedora-updates"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |


Scenario: Upgrade an RPM from path on disk containing wildcards
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade x86_64/glibc*" from repo "dnf-ci-fedora-updates"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
