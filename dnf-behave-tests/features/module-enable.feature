Feature: Enabling module streams


Background:
  Given I use the repository "dnf-ci-fedora-modular"


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
  | module:stream:version           | nodejs:8:20180816123422       |


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


Scenario: Fail to enable a different stream of an already enabled module
   When I execute dnf with args "module enable nodejs:8"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package            |
        | module-stream-enable     | nodejs:8           |
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
   When I execute dnf with args "module enable nodejs:10"
   Then the exit code is 1
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
    And stderr contains "The operation would result in switching of module 'nodejs' stream '8' to stream '10'"
    And stderr contains "Error: It is not possible to switch enabled streams of a module."
