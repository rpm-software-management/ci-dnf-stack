Feature: Test for config option best and commandline options --best and --nobest

  @setup
  Scenario: Feature Setup
      Given repository "test" with packages
         | Package     | Tag      | Value            |
         | TestA       | Version  | 1                |
         |             | Requires | TestA-libs = 1-1 |
         | TestA-libs  | Version  | 1                |
         | TestB       | Version  | 1                |
         |             | Requires | TestB-libs = 1-1 |
         | TestB-libs  | Version  | 1                |
        And repository "updates" with packages
         | Package     | Tag      | Value            |
         | TestA       | Version  | 2                |
         |             | Requires | TestA-libs = 2-1 |
         | TestB       | Version  | 2                |
         |             | Requires | TestB-libs = 2-1 |
       When I enable repository "test"
        And I enable repository "updates"

  @bz1670776 @bz1671683
  Scenario: When installing with best=1 (default), fail on broken packages, and advise to use --nobest
       When I run "dnf -y install TestA"
       Then the command should fail
        And the command stdout should match regexp "try to add .*'--nobest' to use not only best candidate packages"

  @bz1670776 @bz1671683
  Scenario: When installing with option --best, fail on broken packages, and don't advise to use --nobest
       When I run "dnf -y install TestA --best"
       Then the command should fail
        And the command stdout should not match regexp "--nobest"

  Scenario: When installing with best=0, install a package of lower version
       When I save rpmdb
        And I successfully run "dnf -y install TestA --setopt=best=0"
       Then rpmdb changes are
           | State       | Packages              |
           | installed   | TestA/1, TestA-libs/1 |

  @bz1670776 @bz1671683
  Scenario: When installing with option --nobest, install a package of lower version
       When I save rpmdb
        And I successfully run "dnf -y install TestB --nobest"
       Then rpmdb changes are
           | State       | Packages              |
           | installed   | TestB/1, TestB-libs/1 |

  @bz1670776 @bz1671683
  Scenario: When upgrading with best=1 (default), fail on broken packages
        And I run "dnf -y upgrade TestA"
       Then the command should fail

  Scenario: When upgrading with best=0, only report broken packages
       When I save rpmdb
        And I successfully run "dnf -y upgrade TestA --setopt=best=0"
       Then rpmdb does not change

  @bz1670776 @bz1671683
  Scenario: When upgrading with option --nobest, only report broken packages
       When I save rpmdb
        And I successfully run "dnf -y upgrade TestA --nobest"
       Then rpmdb does not change
