Feature: Dependency resolution must occur to determine the appropriate dependent stream+context to use

Background:
  Given I use the repository "dnf-ci-thirdparty-modular"

Scenario: Appropriate context is selected depending on the enabled required module stream
   When I execute dnf with args "module enable biotope:wood"
   Then the exit code is 0
    And modules state is following
        | Module       | State     | Stream     | Profiles  |
        | biotope      | enabled   | wood       |           |
   When I execute dnf with args "module install berry:raspberry/default"
   Then the exit code is 0
    And Transaction is following
        | Action                    | Package                       |
        | module-stream-enable      | berry:raspberry               |
        | module-profile-install    | berry/default                 |
        | install                   | raspberry-0:1.0-1.wood.x86_64 |


Scenario: Appropriate context is selected depending on the enabled required module stream - cross check
   When I execute dnf with args "module enable biotope:garden"
   Then the exit code is 0
    And modules state is following
        | Module       | State     | Stream     | Profiles  |
        | biotope      | enabled   | garden     |           |
   When I execute dnf with args "module install berry:raspberry/default"
   Then the exit code is 0
    And Transaction is following
        | Action                    | Package                           |
        | module-stream-enable      | berry:raspberry                   |
        | module-profile-install    | berry/default                     |
        | install                   | raspberry-0:1.0-1.garden.x86_64   |


Scenario: Any suitable context is selected when more options are possible
   When I execute dnf with args "module install berry:raspberry/default"
   Then the exit code is 0
    And modules state is following
        | Module       | State     | Stream     | Profiles  |
        | berry        | enabled   | raspberry  | default   |
        | biotope      | enabled   | ?          |           |
   When I execute rpm with args "-q raspberry"
   Then the exit code is 0


Scenario: An error is printed with no stream and context is possible to enable
   When I execute dnf with args "module enable biotope:pond"
   Then the exit code is 0
   When I execute dnf with args "module enable berry:raspberry"
   Then the exit code is 1
    And stderr contains "Modular dependency problems:"
    And stderr contains "module biotope:pond.* conflicts with module\(biotope:garden\)"
    And stderr contains "module biotope:pond.* conflicts with module\(biotope:wood\)"


@bz1670496
Scenario: An error is printed when trying to install different context
   When I execute dnf with args "module enable biotope:pond"
   Then the exit code is 0
   When I execute dnf with args "module install berry:raspberry/default"
   Then the exit code is 1
    And stderr contains "Modular dependency problems:"
    And stderr contains "module biotope:pond.* conflicts with module\(biotope:garden\)"
    And stderr contains "module biotope:pond.* conflicts with module\(biotope:wood\)"
