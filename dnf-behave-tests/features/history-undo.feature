@global_dnf_context
Feature: Transaction history undo

Background:
  Given I use the repository "dnf-ci-fedora"

Scenario: History list of simple transaction
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | install       | setup-0:2.12.1-1.fc29.noarch               |
        | install       | filesystem-0:3.9-2.fc29.x86_64             |
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 1      | install filesystem    | Install       | 2         |  

Scenario: Undo last transaction
   When I execute dnf with args "history undo last"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | remove        | setup-0:2.12.1-1.fc29.noarch               |
        | remove        | filesystem-0:3.9-2.fc29.x86_64             |
    And History is following
        | Id     | Command       | Action        | Altered   |
        | 2      |               | Removed       | 2         |  
        | 1      |               | Install       | 2         |  

Scenario: Undo last transaction again
   When I execute dnf with args "history undo last"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | install       | setup-0:2.12.1-1.fc29.noarch               |
        | install       | filesystem-0:3.9-2.fc29.x86_64             |
    And History is following
        | Id     | Command       | Action        | Altered   |
        | 3      |               | Install       | 2         |  
        | 2      |               | Removed       | 2         |  
        | 1      |               | Install       | 2         |  

Scenario: Undo transaction last-2
   When I execute dnf with args "history undo last-2"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | remove        | setup-0:2.12.1-1.fc29.noarch               |
        | remove        | filesystem-0:3.9-2.fc29.x86_64             |
    And History is following
        | Id     | Command       | Action        | Altered   |
        | 4      |               | Removed       | 2         |  
        | 3      |               | Install       | 2         |  
        | 2      |               | Removed       | 2         |  
        | 1      |               | Install       | 2         |  
