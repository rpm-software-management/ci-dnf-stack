Feature: Create new transaction history database


Scenario: Reset the history database
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install setup"
   Then the exit code is 0
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 1      | install setup         | Install       | 1         |  
   When I execute dnf with args "history new"
   Then the exit code is 0
    And History is following
        | Id     | Command               | Action        | Altered   |
   When I execute dnf with args "remove setup"
   Then the exit code is 0
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 1      | remove setup          | Removed       | 1         |  
