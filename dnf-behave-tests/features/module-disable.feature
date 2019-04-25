Feature: Disabling module stream


Background:
  Given I use the repository "dnf-ci-fedora-modular"
  Given I use the repository "dnf-ci-fedora"


@not.with_os=rhel__eq__8
@bz1677640
Scenario: I can disable a module when specifying module name
   When I execute dnf with args "module enable nodejs:8"
   Then the exit code is 0
   When I execute dnf with args "module disable nodejs"
   Then the exit code is 0
    And stdout contains "Disabling modules:"
    And Transaction is following
        | Action                    | Package           |
        | module-disable            | nodejs            |
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | disabled  |           |           |


# this is not test for @bz1677640, but test is failing until the bug is fixed
@not.with_os=rhel__eq__8
Scenario: Disabling an already disabled module should pass
   When I execute dnf with args "module enable nodejs:8"
   Then the exit code is 0
   When I execute dnf with args "module disable nodejs"
   Then the exit code is 0
    And Transaction is following
        | Action                    | Package           |
        | module-disable            | nodejs            |
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | disabled  |           |           |
   When I execute dnf with args "module disable nodejs"
   Then the exit code is 0
    And stdout contains "Nothing to do."


@not.with_os=rhel__eq__8
@bz1649261
Scenario Outline: I can disable a module when specifying <spec>
   When I execute dnf with args "module enable nodejs:8"
   Then the exit code is 0
   When I execute dnf with args "module disable <modulespec>"
   Then the exit code is 0
    And stdout contains "Only module name is required. Ignoring unneeded information in argument: '<modulespec>'"
    And Transaction is following
        | Action                    | Package           |
        | module-disable            | nodejs            |
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | disabled  |           |           |

Examples:
    | spec              | modulespec                |
    | stream            | nodejs:10                 |
    | version           | nodejs:10:20180920144631  |


@not.with_os=rhel__eq__8
@bz1649261
Scenario Outline: I can disable a module with installed profile when specifying <spec>
   When I execute dnf with args "module install nodejs:10/default"
   Then the exit code is 0
   When I execute dnf with args "module disable <modulespec>"
   Then the exit code is 0
    And stdout contains "Only module name is required. Ignoring unneeded information in argument: '<modulespec>'"
    And Transaction is following
        | Action                    | Package           |
        | module-disable            | nodejs            |
        | module-profile-disable    | nodejs/default    |
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | disabled  |           |           |

Examples:
    | spec              | modulespec                |
    | stream            | nodejs:10                 |
    | other stream      | nodejs:8                  |
    | version           | nodejs:10:20180920144631  |


@bz1613910
Scenario: It is possible to disable an enabled default stream
   When I execute dnf with args "module enable nodejs"
   Then the exit code is 0
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
   When I execute dnf with args "module disable nodejs"
   Then the exit code is 0
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | disabled  |           |           |
   When I execute dnf with args "module list nodejs"
   Then the exit code is 0
    And module list contains
        | Repository                    | Name          | Stream    | Profiles                      |
        | dnf-ci-fedora-modular         | nodejs        | 8 [d][x]     | development, minimal, default [d]|


@bz1583596
Scenario: User is informed about disabling installed profiles when disabling a module
   When I execute dnf with args "module install nodejs:10/default nodejs:10/development"
   Then the exit code is 0
   When I execute dnf with args "module install postgresql:9.6/client"
   Then the exit code is 0
    And modules state is following
        | Module    | State     | Stream    | Profiles              |
        | nodejs    | enabled   | 10        | development, default  |
        | postgresql| enabled   | 9.6       | client                |
   When I execute dnf with args "module disable nodejs"
   Then the exit code is 0
    And Transaction is following
        | Action                    | Package               |
        | module-disable            | nodejs                |
        | module-profile-disable    | nodejs/default        |
        | module-profile-disable    | nodejs/development    |
