Feature: Installing modules without profile specification using defaults from repo


Background:
  Given I use the repository "dnf-ci-thirdparty"


Scenario: Install module, no default profile defined, expecting no profile selection
   When I execute dnf with args "module install DnfCiModuleNoDefaults:stable"
   Then the exit code is 0
    And modules state is following
        | Module                | State     | Stream    | Profiles  |
        | DnfCiModuleNoDefaults | enabled   | stable    |           |


Scenario: Install module, empty default profile exists, expecting default profile selection
   When I execute dnf with args "module install DnfCiModuleEmptyDefault:stable"
   Then the exit code is 0
    And modules state is following
        | Module                    | State     | Stream    | Profiles  |
        | DnfCiModuleEmptyDefault   | enabled   | stable    | server    |
    And Transaction is following
        | Action                    | Package                                       |
        | module-stream-enable      | DnfCiModuleEmptyDefault:stable                |
        | module-profile-install    | DnfCiModuleEmptyDefault/server                |

Scenario: Install module, populated default profile exists, expecting default profile selection
   When I execute dnf with args "module install DnfCiModulePopulatedDefault:stable"
   Then the exit code is 0
    And modules state is following
        | Module                        | State     | Stream    | Profiles  |
        | DnfCiModulePopulatedDefault   | enabled   | stable    | server    |
    And Transaction is following
        | Action                    | Package                                       |
        | module-stream-enable      | DnfCiModulePopulatedDefault:stable            |
        | module-profile-install    | DnfCiModulePopulatedDefault/server            |
        | install                   | peer-gynt-0:1.0-1.module.x86_64               |
