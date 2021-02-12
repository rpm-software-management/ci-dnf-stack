Feature: Disabling module stream using microdnf


Background:
  Given I use repository "microdnf-module-enable"
  Given I use repository "dnf-ci-fedora"
   When I execute microdnf with args "module enable nodejs:8"
   Then the exit code is 0
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |


@bz1827424
Scenario: I can disable a module when specifying module name
   When I execute microdnf with args "module disable nodejs"
   Then the exit code is 0
    And stdout contains "Disabling modules:"
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | disabled  |           |           |


@bz1827424
Scenario: Disabling an already disabled module should pass
   When I execute microdnf with args "module disable nodejs"
   Then the exit code is 0
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | disabled  |           |           |
   When I execute microdnf with args "module disable nodejs"
   Then the exit code is 0
    And stdout contains "Nothing to do."


@bz1827424
Scenario Outline: I can disable a module when specifying <spec>
   When I execute microdnf with args "module disable <modulespec>"
   Then the exit code is 0
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | disabled  |           |           |

Examples:
    | spec              | modulespec                |
    | stream            | nodejs:10                 |
    | version           | nodejs:10:20180920144631  |


@bz1827424
Scenario: It is possible to disable an enabled default stream
  When I execute microdnf with args "module disable nodejs"
   Then the exit code is 0
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | disabled  |           |           |
   When I execute dnf with args "module list nodejs"
   Then the exit code is 0
    And module list contains
        | Repository             | Name   | Stream   | Profiles                          |
        | microdnf-module-enable | nodejs | 8 [d][x] | development, minimal, default [d] |
