@xfail
Feature: Installing updating and removing a package in dnf shell

  Scenario: Installing packages
    Given repository "TestRepoA" with packages
         | Package | Tag       | Value |
         |  TestA  |           |       |
         |  TestB  |           |       |
      And I have dnf shell session opened with parameters "-y"
     When I save rpmdb
      And I run dnf shell command "repo enable TestRepoA"
      And I run dnf shell command "install TestA TestB"
      And I run dnf shell command "run"
     Then rpmdb changes are
         | State     | Packages     |
         | installed | TestA, TestB |
     When I run dnf shell command "exit"
     Then the command stdout should match exactly
          """
          Leaving Shell

          """

  Scenario: Updating package using the upgrade command
    Given repository "TestRepoB" with packages
         | Package | Tag       | Value |
         | TestA   | Release   |   2   |
      And I have dnf shell session opened with parameters "-y"
     When I save rpmdb
      And I run dnf shell command "repo enable TestRepoB"
      And I run dnf shell command "upgrade TestA"
      And I run dnf shell command "run"
     Then rpmdb changes are
         | State   | Packages |
         | updated | TestA    |
     When I run dnf shell command "exit"
     Then the command stdout should match exactly
          """
          Leaving Shell

          """

  Scenario: Updating package using the update command
    Given repository "TestRepoC" with packages
         | Package | Tag       | Value |
         | TestB   | Release   |   2   |
      And I have dnf shell session opened with parameters "-y"
     When I save rpmdb
      And I run dnf shell command "repo enable TestRepoC"
      And I run dnf shell command "update TestB"
      And I run dnf shell command "run"
     Then rpmdb changes are
         | State   | Packages |
         | updated | TestB    |
     When I run dnf shell command "exit"
     Then the command stdout should match exactly
          """
          Leaving Shell

          """

  Scenario: Removing a package
    Given I have dnf shell session opened with parameters "-y"
     When I save rpmdb
      And I run dnf shell command "remove TestA"
      And I run dnf shell command "run"
     Then rpmdb changes are
         | State     | Packages |
         | removed   | TestA    |
     When I run dnf shell command "exit"
     Then the command stdout should match exactly
          """
          Leaving Shell

          """

  Scenario: Installing and erasing a package within one transaction
    Given I have dnf shell session opened with parameters "-y"
     When I save rpmdb
      And I run dnf shell command "repo enable TestRepoA"
      And I run dnf shell command "install TestA"
      And I run dnf shell command "erase TestB"
      And I run dnf shell command "run"
     Then rpmdb changes are
         | State     | Packages |
         | installed | TestA    |
         | removed   | TestB    |
     When I run dnf shell command "exit"
     Then the command stdout should match exactly
          """
          Leaving Shell

          """
