Feature: Enabling module streams using microdnf


Background:
  Given I use repository "microdnf-module-enable"


@bz1827424
Scenario Outline: Enable a module stream by <modulespec-type>
   When I execute microdnf with args "module enable <modulespec>"
   Then the exit code is 0
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


@bz1827424
Scenario: Enable a module stream that was already enabled
   When I execute microdnf with args "module enable nodejs:8"
   Then the exit code is 0
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
   When I execute microdnf with args "module enable nodejs:8"
   Then the exit code is 0
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
