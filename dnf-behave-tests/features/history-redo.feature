Feature: Transaction history redo

Scenario: Redo last transaction
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | install       | setup-0:2.12.1-1.fc29.noarch               |
        | install       | filesystem-0:3.9-2.fc29.x86_64             |
   When I execute dnf with args "remove filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | remove        | setup-0:2.12.1-1.fc29.noarch               |
        | remove        | filesystem-0:3.9-2.fc29.x86_64             |
   When I execute dnf with args "history redo last-1"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | install       | setup-0:2.12.1-1.fc29.noarch               |
        | install       | filesystem-0:3.9-2.fc29.x86_64             |
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 3      |                       | Install       | 2         |  
        | 2      |                       | Removed       | 2         |  
        | 1      | install filesystem    | Install       | 2         |  
   When I execute dnf with args "history redo last-1"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | remove        | setup-0:2.12.1-1.fc29.noarch               |
        | remove        | filesystem-0:3.9-2.fc29.x86_64             |
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 4      |                       | Removed       | 2         |  
        | 3      |                       | Install       | 2         |  
        | 2      |                       | Removed       | 2         |  
        | 1      |                       | Install       | 2         |  
