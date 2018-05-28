Feature: Both ursine packages and modules are updated during dnf update

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
	And repository "ursinePkgRepo" with packages
           | Package  | Tag      | Value |
           | TestU    | Version  | 1     |
           |          | Release  | 1     |
           | TestU r2 | Version  | 1     |
	   |          | Release  | 2     |
           |          | Requires | TestV |
           | TestV    | Version  | 1     |
       When I enable repository "modularityABDE"
        And I enable repository "ursinePkgRepo"
        And I successfully run "dnf makecache"

  @xfail  # bz#1583059
  Scenario: Both ursine packages and modules are updated during dnf update
      Given I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module install -y ModuleA:f26:1/client"
	And I successfully run "dnf install -y TestU-1-1"
       When I save rpmdb
        And I successfully run "dnf -y update"
       Then rpmdb changes are
          | State     | Packages                  |
          | upgraded  | TestA/1-2.modA, TestU/1-2 |
          | installed | TestV/1-1                 |
          | unchanged | TestB/1-1.modA            |
        And a module ModuleA config file should contain
          | Key     | Value |
          | version | 2     |
