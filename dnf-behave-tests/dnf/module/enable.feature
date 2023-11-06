Feature: Enabling module streams


Background:
  Given I use repository "dnf-ci-fedora-modular"


Scenario Outline: Enable a module stream by <modulespec-type>
   When I execute dnf with args "module enable <modulespec>"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package            |
        | module-stream-enable     | nodejs:8           |
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |

Examples:
  | modulespec-type                 | modulespec                    |
  | module:stream                   | nodejs:8                      |
  | module:stream:version           | nodejs:8:20180801080000       |
  | glob                            | node*                         |
  | glob:glob                       | node*:*                       |
  | glob:glob:glob                  | node*:*:*0801*                |


@dnf5
Scenario: Enable a module stream that was already enabled
   When I execute dnf with args "module enable nodejs:8"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package            |
        | module-stream-enable     | nodejs:8           |
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
   When I execute dnf with args "module enable nodejs:8"
   Then the exit code is 0
    And Transaction is empty
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
