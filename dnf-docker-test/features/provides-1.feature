Feature: Test for dnf provides

  @setup
  Scenario: Setup (create test repo)
      Given repository "base" with packages
         | Package      | Tag       | Value         |
         | TestA        | Version   | 1             |
         |              | Requires  | TestB         |
         | TestC        | Version   | 1             |
         | TestD        | Version   | 1             |
         |              | Provides  | TestB         |
         | TestE        | Version   | 1             |
         |              | Provides  | TestEVal      |
        And repository "update" with packages
         | Package      | Tag       | Value         |
         | TestA        | Version   | 2             |
         |              | Requires  | TestB         |
         | TestC        | Version   | 2             |
         |              | Provides  | TestB         |
         |              | Conflicts | TestD         |
         | TestD        | Version   | 2             |
         |              | Provides  | TestB         |
         |              | Conflicts | TestC         |
         | TestE        | Version   | 2             |
         |              | Provides  | TestEVal      |
      When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA TestC TestD"
        And I disable repository "base"
      Then rpmdb changes are
        | State     | Packages            |
        | installed | TestA, TestC, TestD |      

  Scenario: dnf provides TestB - installed package TestD-1 provides TestB
       When I successfully run "dnf provides TestB"
       Then the command stdout should match regexp "TestD-1-[^R]+Repo[ \t]+: @System"
        And the command stdout should not match regexp "(Test[ACE]-1-)|(Test[ACDE]-2-)"

  Scenario: dnf provides TestB - package TestD-1 (installed and in base repo) provides TestB
       When I enable repository "base"
        And I successfully run "dnf provides TestB"
       Then the command stdout should match regexp "TestD-1-[^R]+Repo[ \t]+: @System"
        And the command stdout should match regexp "TestD-1-[^R]+Repo[ \t]+: base"
        And the command stdout should not match regexp "(Test[ACE]-1-)|(Test[ACDE]-2-)"

  Scenario: dnf provides TestB - packages TestD-1 (installed and in base repo), TestC-2 and TestD-2 (in update repo) provides TestB
       When I enable repository "update"
        And I successfully run "dnf provides TestB"
       Then the command stdout should match regexp "TestD-1-[^R]+Repo[ \t]+: @System"
        And the command stdout should match regexp "TestD-1-[^R]+Repo[ \t]+: base"
        And the command stdout should match regexp "TestC-2-[^R]+Repo[ \t]+: update"
        And the command stdout should match regexp "TestD-2-[^R]+Repo[ \t]+: update"
        And the command stdout should not match regexp "(Test[ACE]-1-)|(Test[AE]-2-)"

  Scenario: dnf provides nonexistentprovide
       When I run "dnf provides nonexistentprovide"
       Then the command exit code is 1
        And the command stderr should match regexp "No Matches found"
