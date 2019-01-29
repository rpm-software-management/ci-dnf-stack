Feature: Test for dnf list (including all documented suboptions and yum compatibility)
 repo base: TestA-1 TestB-1
 repo ext: XTest-2 TestA-2 TestB-2

  @setup
  Scenario: Setup (create test repos)
      Given repository "base" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 1         |
         | TestB        | Version  | 1         |
      Given repository "long_names" with packages
         | Package                                        | Tag      | Value                            |
         | superMegaLongNameOfPackage                     | Version  | 1234567890.123456789101112131415 |
         | purposeOfTheseNamesIsToBreakDNFOuput           | Version  | 2234567890.123123123123123123123 |
         | whichIsKnownToBeVulnerableWhenPipedToGrep      | Version  | 3234567890.123123123123123123123 |
         | forTestingPurposesWeEvenHaveReallyLongVersions | Version  | 1435347658326856238756823658aaaa |
        And repository "ext" with packages
         | Package      | Tag      | Value     |
         | XTest        | Version  | 2         |
         |              | Obsoletes| TestB     |
         | TestA        | Version  | 2         |
         | TestB        | Version  | 2         |

  Scenario: dnf list recent (recently added are pkgs in the ext repo)
       When I successfully run "dnf list recent"
       Then the command stdout section "Recently Added Packages" should match regexp "TestA.*2-1"
        And the command stdout section "Recently Added Packages" should match regexp "TestB.*2-1"
        And the command stdout section "Recently Added Packages" should match regexp "XTest.*2-1"
        And the command stdout should not match regexp "TestA.*1-1"
        And the command stdout should not match regexp "TestB.*1-1"

  Scenario: dnf list --recent (recently added are pkgs in the ext repo)
       When I successfully run "dnf list --recent"
       Then the command stdout section "Recently Added Packages" should match regexp "TestA.*2-1"
        And the command stdout section "Recently Added Packages" should match regexp "TestB.*2-1"
        And the command stdout section "Recently Added Packages" should match regexp "XTest.*2-1"
        And the command stdout should not match regexp "TestA.*1-1"
        And the command stdout should not match regexp "TestB.*1-1"

  Scenario: dnf list recent TestC (when TestC is not recently added)
       When I run "dnf list recent TestC"
       Then the command exit code is 1
        And the command stderr should match regexp "No matching Packages"
