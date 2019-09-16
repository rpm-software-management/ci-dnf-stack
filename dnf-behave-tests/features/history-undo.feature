Feature: Transaction history undo

Background:
  Given I use the repository "dnf-ci-fedora"

Scenario: Undoing transactions
  Given I successfully execute dnf with args "install filesystem"
   Then History is following
        | Id     | Command               | Action        | Altered   |
        | 1      | install filesystem    | Install       | 2         |  
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

@1627111
Scenario: Handle missing packages required for undoing the transaction
    When I execute dnf with args "install wget flac" 
    Then the exit code is 0
     And Transaction is following
         | Action        | Package                      |
         | install       | wget-0:1.19.5-5.fc29.x86_64  |
         | install       | flac-0:1.3.2-8.fc29.x86_64   |
   When I disable the repository "dnf-ci-fedora"
    And I use the repository "dnf-ci-fedora-updates"
   Then I execute dnf with args "update"
    Then the exit code is 0
     And Transaction is following
         | Action        | Package                      |
         | upgrade       | flac-0:1.3.3-3.fc29.x86_64   |
         | upgrade       | wget-0:1.19.6-5.fc29.x86_64  |
     Then I execute dnf with args "history undo last"
     Then the exit code is 1
     And Transaction is empty
     And stderr contains "No package flac-1.3.2-8.fc29.x86_64 available."
     And stderr contains "No package wget-1.19.5-5.fc29.x86_64 available."
     And stderr contains "Error: no package matched"

