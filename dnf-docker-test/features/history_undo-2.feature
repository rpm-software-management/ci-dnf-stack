Feature: history undo error handling

  @setup
  Scenario: Feature Setup
      Given repository "base" with packages
          | Package | Tag       | Value |
          | TestA   |           |       |
          | TestB   |           |       |
        And repository "update" with packages
          | Package | Tag       | Value |
          | TestA   | Version   | 2     |
          | TestB   | Version   | 2     |
       When I enable repository "base"

  @bz1627111
  Scenario: Handle missing packages required for undoing the transaction
      Given I successfully run "dnf -y install TestA TestB"
       When I disable repository "base"
        And I enable repository "update"
        And I successfully run "dnf -y update"
        And I save rpmdb
        And I run "dnf history undo last -y"
       Then the command should fail
        And the command stderr should match regexp "No package TestA-1-1.noarch available."
        And the command stderr should match regexp "No package TestB-1-1.noarch available."
        And the command stderr should match regexp "Error: no package matched"
        And rpmdb does not change
