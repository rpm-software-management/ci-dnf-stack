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



@bz1618421
Scenario: Installing a module and its dependencies, non-modular dependency available
   When I execute dnf with args "module install meson:master/default"
   Then the exit code is 0
    And Transaction contains
        | Action                    | Package                                       |
        | install                   | meson-0:0.47.1-5.module_1993+7c0a4d1e.noarch  |
        | install                   | ninja-build-0:1.8.2-4.module_1991+4e5efe2f.x86_64 |
        | module-stream-enable      | meson:master                                  |
        | module-stream-enable      | ninja:master                                  |
        | module-profile-install    | meson/default                                 |


@bz1618421
Scenario: Installing a module and its dependencies, non-modular dependency is not available
  Given I disable the repository "dnf-ci-fedora"
   When I execute dnf with args "module install meson:master/default"
   Then the exit code is 1
    And stderr contains lines
        """
        Problem: package meson-0.47.1-5.module_1993+7c0a4d1e.noarch requires ninja-build, but none of the providers can be installed
        - nothing provides rtld(GNU_HASH) needed by ninja-build-1.8.2-4.module_1991+4e5efe2f.x86_64
        """


@bz1622599
@bz1566078
Scenario: Install a module of which all packages and requires are already installed
   When I execute dnf with args "module enable meson:master"
   Then the exit code is 0
   When I execute dnf with args "module install ninja:master/default"
   Then the exit code is 0
   When I execute dnf with args "install meson"
   Then the exit code is 0
    And stdout contains "Installing\s+: meson.*"
   When I execute dnf with args "module install meson:master/default"
   Then the exit code is 0
    And Transaction is following
        | Action                    | Package                                       |
        | module-profile-install    | meson/default                                 |
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | ninja     | enabled   | master    | default   |
        | meson     | enabled   | master    | default   |
    And stderr does not contain "Package meson.* is already installed."


@bz1592408
Scenario: Install a module of which all packages are non-modular
  Given I use the repository "dnf-ci-thirdparty"
   When I execute dnf with args "module install DnfCiModuleNoArtifacts:master/default"
   Then the exit code is 0
    And Transaction is following
        | Action                    | Package                           |
        | install                   | wget-0:1.19.5-5.fc29.x86_64       |
        | install                   | solveigs-song-0:1.0-1.x86_64      |
        | module-profile-install    | DnfCiModuleNoArtifacts/default    |
        | module-stream-enable      | DnfCiModuleNoArtifacts:master     |
    And modules state is following
        | Module                    | State     | Stream    | Profiles  |
        | DnfCiModuleNoArtifacts    | enabled   | master    | default   |
