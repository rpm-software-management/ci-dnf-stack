@xfail
Feature: Installing a package group in dnf shell

Scenario: Installing package group in dnf shell
     Given repository "TestRepo" with packages
          | Package | Tag | Value |
          | TestA   |     |       |
          | TestB   |     |       |
       And package groups defined in repository "TestRepo"
          | Group     | Tag         | Value   |
          | TestGroup | mandatory   | TestA   |
          |           | default     | TestB   |
       And I have dnf shell session opened with parameters "-y"
      When I save rpmdb
       And I run dnf shell command "repo enable TestRepo"
       And I run dnf shell command "group install TestGroup"
       And I run dnf shell command "run"
      Then rpmdb changes are
         | State     | Packages     |
         | installed | TestA, TestB |

Scenario: Updating a package group in dnf shell using the upgrade command
     Given repository "TestRepo2" with packages
          | Package | Tag     | Value |
          | TestA   | Release |   2   |
          | TestB   |         |       |
          | TestC   |         |       |
       And package groups defined in repository "TestRepo2"
          | Group     | Tag         | Value   |
	  | TestGroup | mandatory   | TestA   |
          |           | mandatory   | TestC   |
          |           | default     | TestB   |
       And I have dnf shell session opened with parameters "-y"
      When I save rpmdb
       And I run dnf shell command "repo enable TestRepo2"
       And I run dnf shell command "groups upgrade TestGroup"
       And I run dnf shell command "run"
      Then rpmdb changes are
         | State     | Packages |
         | installed | TestC    |
         | updated   | TestA    |

Scenario: Updating a package group in dnf shell using the update command
     Given repository "TestRepo3" with packages
          | Package | Tag     | Value |
          | TestA   | Release |   2   |
          | TestB   | Release |   2   |
          | TestC   |         |       |
       And package groups defined in repository "TestRepo3"
          | Group     | Tag         | Value   |
	  | TestGroup | mandatory   | TestA   |
          |           | mandatory   | TestC   |
          |           | default     | TestB   |
       And I have dnf shell session opened with parameters "-y"
      When I save rpmdb
       And I run dnf shell command "repo enable TestRepo3"
       And I run dnf shell command "groups update TestGroup"
       And I run dnf shell command "run"
      Then rpmdb changes are
          | State     | Packages |
          | updated   | TestB    |

Scenario: Removing package group in dnf shell
     Given I have dnf shell session opened with parameters "-y"
      When I save rpmdb
       And I run dnf shell command "repo enable TestRepo3"
       And I run dnf shell command "groups remove TestGroup"
       And I run dnf shell command "run"
      Then rpmdb changes are
          | State   | Packages            |
          | removed | TestA, TestB, TestC |

