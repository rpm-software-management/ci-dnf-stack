Feature: Test for alias command

  @setup
  Scenario: Preparing the test repository
      Given repository "base" with packages
         | Package | Tag     | Value |
         | TestA   | Version | 1     |
         |         | Release | 1     |

  Scenario: Add alias
    When I successfully run "dnf alias add inthrone=install"
    Then The command stdout should match regexp "^Aliases added: inthrone$"

  @xfail @bz1666325
  Scenario: List aliases
    When I successfully run "dnf alias list"
    Then The command stdout should match regexp "^Alias inthrone='install'$"

  Scenario: Use alias
    When I save rpmdb
     And I enable repository "base"
     And I successfully run "dnf -y inthrone TestA"
    Then rpmdb changes are
      | State     | Packages |
      | installed | TestA    |

  Scenario: Delete alias
    When I successfully run "dnf alias delete inthrone"
    Then The command stdout should match regexp "^Aliases deleted: inthrone$"
    When I successfully run "dnf alias list"
    Then The command stdout should match regexp "^No aliases defined.$"
    When I run "dnf -y inthrone TestA"
    Then The command should fail
     And The command stderr should match regexp "^No such command: inthrone"
