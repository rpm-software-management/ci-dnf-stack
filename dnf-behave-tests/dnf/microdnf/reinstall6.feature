Feature: Reinstall


Scenario: Reinstall a pkg that has an identical Provide and a Conflict
  Given I use repository "reinstall-provides-conflict"
    And I successfully execute microdnf with args "install hello"
   When I execute microdnf with args "reinstall hello"
   Then the exit code is 0
    And RPMDB Transaction is following
        | Action        | Package                   |
        | reinstall     | hello-0:1.0-1.fc29.x86_64 |
