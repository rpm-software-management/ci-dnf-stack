Feature: Transaction history redo

# TODO redoing the transactions doesn't preserve the corrent "reason"
# (installed/removed as a dependency)
Scenario: Redo last transaction
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | install       | filesystem-0:3.9-2.fc29.x86_64             |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch               |
   When I execute dnf with args "remove filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | remove        | filesystem-0:3.9-2.fc29.x86_64             |
        | remove-unused | setup-0:2.12.1-1.fc29.noarch               |
   When I execute dnf with args "history redo last-1"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | install       | filesystem-0:3.9-2.fc29.x86_64             |
        | install       | setup-0:2.12.1-1.fc29.noarch               |
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 3      |                       | Install       | 2         |  
        | 2      |                       | Removed       | 2         |  
        | 1      | install filesystem    | Install       | 2         |  
   When I execute dnf with args "history redo last-1"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | remove        | filesystem-0:3.9-2.fc29.x86_64             |
        | remove        | setup-0:2.12.1-1.fc29.noarch               |
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 4      |                       | Removed       | 2         |  
        | 3      |                       | Install       | 2         |  
        | 2      |                       | Removed       | 2         |  
        | 1      |                       | Install       | 2         |  
