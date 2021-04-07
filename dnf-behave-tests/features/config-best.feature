Feature: Config option: best


Scenario: Verify that repo priorities work
  Given I use repository "dnf-ci-fedora"
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install glibc --setopt=dnf-ci-fedora.priority=90 --setopt=best=0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | glibc-0:2.28-9.fc29.x86_64            |
        | install-dep   | glibc-common-0:2.28-9.fc29.x86_64     |
        | install-dep   | glibc-all-langpacks-0:2.28-9.fc29.x86_64      |
        | install-dep   | basesystem-0:11-6.fc29.noarch         |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |


Scenario: When priority repo is broken and best=0, install a package from repo with lower priority
  Given I use repository "dnf-ci-fedora"
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install glibc --setopt=dnf-ci-fedora.priority=90 --setopt=best=0 -x glibc-common-0:2.28-9.fc29.x86_64"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | glibc-0:2.28-26.fc29.x86_64           |
        | install-dep   | glibc-common-0:2.28-26.fc29.x86_64    |
        | install-dep   | glibc-all-langpacks-0:2.28-26.fc29.x86_64     |
        | install-dep   | basesystem-0:11-6.fc29.noarch         |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |
        | broken        | glibc-0:2.28-9.fc29.x86_64            |


Scenario: When installing with option --nobest, install a package from repo with lower priority
  Given I use repository "dnf-ci-fedora"
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install glibc --setopt=dnf-ci-fedora.priority=90 --nobest -x glibc-common-0:2.28-9.fc29.x86_64"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | glibc-0:2.28-26.fc29.x86_64           |
        | install-dep   | glibc-common-0:2.28-26.fc29.x86_64    |
        | install-dep   | glibc-all-langpacks-0:2.28-26.fc29.x86_64     |
        | install-dep   | basesystem-0:11-6.fc29.noarch         |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |
        | broken        | glibc-0:2.28-9.fc29.x86_64            |


@bz1670776 @bz1671683
Scenario: When installing with best=1 set in dnf.conf, fail on broken packages, and advise to use --nobest
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install glibc -x glibc-common-0:2.28-26.fc29.x86_64"
   Then the exit code is 1
    And stdout contains "try to add .*'--nobest' to use not only best candidate packages"


@bz1670776 @bz1671683
Scenario: When installing with option --best, fail on broken packages, and don't advise to use --nobest
  Given I use repository "dnf-ci-fedora"
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install glibc --best -x glibc-common-0:2.28-26.fc29.x86_64"
   Then the exit code is 1
    And stdout does not contain "--nobest"


Scenario: When installing with best=0, install a package of lower version
  Given I use repository "dnf-ci-fedora"
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install glibc --setopt=best=0 -x glibc-common-0:2.28-26.fc29.x86_64"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install-dep   | glibc-common-0:2.28-9.fc29.x86_64         |
        | install-dep   | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
        | install-dep   | basesystem-0:11-6.fc29.noarch             |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64            |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
        | broken        | glibc-0:2.28-26.fc29.x86_64               |


@bz1670776 @bz1671683
Scenario: When installing with option --nobest, install a package of lower version
  Given I use repository "dnf-ci-fedora"
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install glibc --nobest -x glibc-common-0:2.28-26.fc29.x86_64"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install-dep   | glibc-common-0:2.28-9.fc29.x86_64         |
        | install-dep   | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
        | install-dep   | basesystem-0:11-6.fc29.noarch             |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64            |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
        | broken        | glibc-0:2.28-26.fc29.x86_64               |


Scenario: When upgrading with best=0, only report broken packages
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | glibc-0:2.28-9.fc29.x86_64            |
        | install-dep   | glibc-common-0:2.28-9.fc29.x86_64     |
        | install-dep   | glibc-all-langpacks-0:2.28-9.fc29.x86_64      |
        | install-dep   | basesystem-0:11-6.fc29.noarch         |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade --setopt=best=0 -x glibc-common-0:2.28-26.fc29.x86_64"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | broken        | glibc-0:2.28-26.fc29.x86_64           |
        | broken        | glibc-all-langpacks-0:2.28-26.fc29.x86_64     |


@bz1670776 @bz1671683
Scenario: When upgrading with option --nobest, only report broken packages
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | glibc-0:2.28-9.fc29.x86_64            |
        | install-dep   | glibc-common-0:2.28-9.fc29.x86_64     |
        | install-dep   | glibc-all-langpacks-0:2.28-9.fc29.x86_64      |
        | install-dep   | basesystem-0:11-6.fc29.noarch         |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade --nobest -x glibc-common-0:2.28-26.fc29.x86_64"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | broken        | glibc-0:2.28-26.fc29.x86_64           |
        | broken        | glibc-all-langpacks-0:2.28-26.fc29.x86_64     |

@bz1670776 @bz1671683
Scenario: When upgrading with best=1 (default), fail on broken packages
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | glibc-0:2.28-9.fc29.x86_64            |
        | install-dep   | glibc-common-0:2.28-9.fc29.x86_64     |
        | install-dep   | glibc-all-langpacks-0:2.28-9.fc29.x86_64      |
        | install-dep   | basesystem-0:11-6.fc29.noarch         |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade -x glibc-common-0:2.28-26.fc29.x86_64 --best"
   Then the exit code is 1

# top requires middle (middle-0.15 and middle-0.18 available)
# middle requires bottom (bottom-2.26 and bottom-2.48 available)
# middle-0.18 requires bottom >= 2.48
@bz1946975
Scenario: Installed lower version of 2nd level dependency does not prevent installation of the best dependencies versions
  Given I use repository "best"
    # install older version of 2nd level dependency
    And I successfully execute dnf with args "install bottom-2.26"
   When I execute dnf with args "install --best top"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | top-0:3.0-1.fc29.noarch               |
        | install-dep   | middle-0:0.18-1.fc29.noarch           |
        | upgrade       | bottom-0:2.48-1.fc29.noarch           |



