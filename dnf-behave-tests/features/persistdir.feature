Feature: Track information in persistdir


Scenario: Persistdir is created during transaction
  Given I use repository "dnf-ci-fedora"
   Then the installroot path "/var/lib/dnf" does NOT exist
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |
    And the installroot path "/var/lib/dnf" exists
