@global_dnf_context
Feature: History of update

Scenario: History of update packages
  Given I use the repository "dnf-ci-fedora"
   # `install setup` step added so that `install abcde` was not the first
   # transaction in history. Dnf due to some error is not able to
   # rollback the very first transaction.
   When I execute dnf with args "install setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
   Then the exit code is 0
   When I execute dnf with args "install abcde"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | abcde-0:2.9.2-1.fc29.noarch               |
        | install       | flac-0:1.3.2-8.fc29.x86_64                |
        | install       | wget-0:1.19.5-5.fc29.x86_64               |
   When I enable the repository "dnf-ci-fedora-updates"
    And I execute dnf with args "update"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | flac-0:1.3.3-3.fc29.x86_64                |
        | upgrade       | wget-0:1.19.6-5.fc29.x86_64               |
        | upgrade       | abcde-0:2.9.3-1.fc29.noarch               |
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 3      | update                | Upgrade       | 3         |  
        | 2      |                       | Install       | 3         |  
        | 1      |                       | Install       | 1         |  


Scenario: Rollback update
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "history rollback last-1"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | downgrade     | abcde-0:2.9.2-1.fc29.noarch               |
        | downgrade     | flac-0:1.3.2-8.fc29.x86_64                |
        | downgrade     | wget-0:1.19.5-5.fc29.x86_64               |
   When I execute dnf with args "history rollback last-3"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | abcde-0:2.9.2-1.fc29.noarch               |
        | remove        | flac-0:1.3.2-8.fc29.x86_64                |
        | remove        | wget-0:1.19.5-5.fc29.x86_64               |
