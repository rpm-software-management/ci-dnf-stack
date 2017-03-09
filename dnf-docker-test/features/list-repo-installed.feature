Feature: DNF/Behave test list installed packages from repository

    @setup
    Scenario: Feature Setup
        Given repository "test" with packages
           | Package | Tag      | Value  |
           | TestA   | Requires | TestB  |
           | TestB   | Version  | 4.2    |
          And repository "test2" with packages
           | Package | Tag      | Value  |
           | TestC   | Requires | TestD  |
           | TestD   | Arch     | x86_64 |
           | TestE   | Version  | 6.9    |
         When I save rpmdb
          And I enable repository "test"
          And I enable repository "test2"
          And I successfully run "dnf install -y TestA TestC"
         Then rpmdb changes are
           | State     | Packages                   |
           | installed | TestA, TestB, TestC, TestD |


    Scenario: List all packages available
         When I successfully run "dnf list"
         Then the command stdout should match regexp "TestA\.noarch.*1-1.*test"
          And the command stdout should match regexp "TestB\.noarch.*4\.2-1.*test"
          And the command stdout should match regexp "TestC\.noarch.*1-1.*test2"
          And the command stdout should match regexp "TestD\.x86_64.*1-1.*test2"
          And the command stdout should match regexp "TestE\.noarch.*6\.9-1.*test2"

    Scenario: List packages when all repositories enabled
         When I successfully run "dnf list --installed"
         Then the command stdout should match regexp "TestA\.noarch.*1-1.*test"
          And the command stdout should match regexp "TestB\.noarch.*4\.2-1.*test"
          And the command stdout should match regexp "TestC\.noarch.*1-1.*test2"
          And the command stdout should match regexp "TestD\.x86_64.*1-1.*test2"
          And the command stdout should not match regexp "TestE"

    Scenario: List packages when all repositories enabled (yum compatibility)
         When I successfully run "dnf list installed"
         Then the command stdout should match regexp "TestA\.noarch.*1-1.*test"
          And the command stdout should match regexp "TestB\.noarch.*4\.2-1.*test"
          And the command stdout should match regexp "TestC\.noarch.*1-1.*test2"
          And the command stdout should match regexp "TestD\.x86_64.*1-1.*test2"
          And the command stdout should not match regexp "TestE"

    Scenario: List installed packages from repo "test"
         When I successfully run "dnf repository-packages -q test list --installed"
         Then the command stdout should match exactly
              """
              Installed Packages
              TestA.noarch                             1-1                               @test
              TestB.noarch                             4.2-1                             @test

              """

    Scenario: List installed from repo "test2"
         When I successfully run "dnf repository-packages -q test2 list --installed"
         Then the command stdout should match exactly
              """
              Installed Packages
              TestC.noarch                             1-1                              @test2
              TestD.x86_64                             1-1                              @test2

              """
