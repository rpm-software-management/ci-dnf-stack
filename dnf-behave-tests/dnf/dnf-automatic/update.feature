Feature: dnf-automatic performs update


Background:
Given I use repository "simple-base"


Scenario: dnf-automatic can update package
  Given I successfully execute dnf with args "install labirinto"
    And I use repository "simple-updates"
   When I execute dnf with args "automatic --installupdates"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | upgrade       | labirinto-0:2.0-1.fc29.x86_64         |


@bz1793298
Scenario: dnf-automatic fails to update when the update package is not signed
  Given I successfully execute dnf with args "install labirinto"
    And I use repository "simple-updates" with configuration
        | key      | value  | 
        | gpgcheck | 1      |
   When I execute dnf with args "automatic --installupdates"
   Then the exit code is 1
    And RPMDB Transaction is empty


@bz1793298
Scenario: dnf-automatic fails to update when the public gpg key is not installed
  Given I successfully execute dnf with args "install dedalo-signed-1.0"
    And I use repository "simple-updates" with configuration
        | key      | value  | 
        | gpgcheck | 1      |
   When I execute dnf with args "automatic --installupdates"
   Then the exit code is 1
    And RPMDB Transaction is empty
