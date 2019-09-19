Feature: Upgrade RPMs from path


Background: Install glibc, wget
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install glibc wget"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install       | glibc-common-0:2.28-9.fc29.x86_64         |
        | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
        | install       | wget-0:1.19.5-5.fc29.x86_64               |


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
  Given I set working directory to "{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade x86_64/glibc-2.28-26.fc29.x86_64.rpm x86_64/glibc-common-2.28-26.fc29.x86_64.rpm x86_64/glibc-all-langpacks-2.28-26.fc29.x86_64.rpm"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |


Scenario: Upgrade an RPM from path on disk containing wildcards
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/glibc*"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |


Scenario: Upgrade an RPM from path on disk, when specifying the RPM multiple times
   When I execute dnf with args "upgrade {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/wget-1.19.6-5.fc29.x86_64.rpm {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/wget-1.19.6-5.fc29.x86_64.rpm"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | wget-0:1.19.6-5.fc29.x86_64               |


Scenario: Upgrade an RPM from path on disk, when specifying the RPM multiple times using different paths
   When I execute dnf with args "upgrade x86_64/wget-1.19.6-5.fc29.x86_64.rpm {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/wget-1.19.6-5.fc29.x86_64.rpm"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | wget-0:1.19.6-5.fc29.x86_64               |


Scenario: Upgrade an RPM from path on disk, when specifying the RPM multiple times using symlink
  Given I copy file "{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/wget-1.19.6-5.fc29.x86_64.rpm" to "/tmp/wget-1.19.6-5.fc29.x86_64.rpm"
    And I create symlink "/tmp/symlink.rpm" to file "/tmp/wget-1.19.6-5.fc29.x86_64.rpm"
   When I execute dnf with args "upgrade {context.dnf.installroot}/tmp/wget-1.19.6-5.fc29.x86_64.rpm {context.dnf.installroot}/tmp/symlink.rpm"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | wget-0:1.19.6-5.fc29.x86_64               |

