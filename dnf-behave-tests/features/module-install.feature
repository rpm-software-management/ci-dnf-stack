Feature: Installing module profiles

Background:
  Given I use the repository "dnf-ci-fedora-modular"
    And I use the repository "dnf-ci-fedora"


Scenario: I can install a module profile for an enabled module stream
   When I execute dnf with args "module enable nodejs:8"
   Then the exit code is 0
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
   When I execute dnf with args "module install nodejs/minimal"
   Then the exit code is 0
    And Transaction contains
        | Action                    | Package                                       |
        | install                   | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
        | module-profile-install    | nodejs/minimal                                |


@bz1609919
Scenario: I can install a module profile by name:stream/profile
   When I execute dnf with args "module install nodejs:8/minimal"
   Then the exit code is 0
    And Transaction contains
        | Action                    | Package                                       |
        | install                   | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
        | module-profile-install    | nodejs/minimal                                |
        | module-stream-enable      | nodejs:8                                      |
    And stdout contains "Installing group/module packages"


Scenario: I can install multiple module profiles at the same time
   When I execute dnf with args "module enable postgresql:9.6"
   Then the exit code is 0
   When I execute dnf with args "module install postgresql/client postgresql/server"
   Then the exit code is 0
    And modules state is following
        | Module        | State     | Stream    | Profiles      |
        | postgresql    | enabled   | 9.6       | client,server |
    And Transaction contains
        | Action                    | Package                                       |
        | install                   | postgresql-server-0:9.6.8-1.module_1710+b535a823.x86_64 |
        | install                   | postgresql-0:9.6.8-1.module_1710+b535a823.x86_64 |



@1622599
Scenario: Installing a module profile with RPMs manually installed previously should do nothing
   When I execute dnf with args "module enable postgresql:9.6"
   Then the exit code is 0
   When I execute dnf with args "install postgresql"
   Then the exit code is 0
   When I execute dnf with args "module install postgresql:9.6/client"
   Then the exit code is 0
    And Transaction is following
        | Action                    | Package                                       |
        | module-profile-install    | postgresql/client                             |
    And stderr does not contain "Package postgresql-9.6.8-1.module_1710+b535a823.x86_64 is already installed."


Scenario: Installing a module and its dependencies
   When I execute dnf with args "module install meson:master/default"
   Then the exit code is 0
    And Transaction contains
        | Action                    | Package                                       |
        | install                   | meson-0:0.47.1-5.module_1993+7c0a4d1e.noarch  |
        | install                   | ninja-build-0:1.8.2-4.module_1991+4e5efe2f.x86_64 |
        | module-stream-enable      | meson:master                                  |
        | module-stream-enable      | ninja:master                                  |
        | module-profile-install    | meson/default                                 |
