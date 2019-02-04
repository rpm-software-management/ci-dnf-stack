@global_dnf_context
Feature: Modules listing

Background:
  Given I use the repository "dnf-ci-fedora-modular"
    And I use the repository "dnf-ci-fedora-modular-updates"
    And I use the repository "dnf-ci-fedora"

Scenario: I can list all available modules
   When I execute dnf with args "module enable nodejs:8"
   Then the exit code is 0
   When I execute dnf with args "module install nodejs:8/minimal"
   Then the exit code is 0
   When I execute dnf with args "module enable postgresql:11"
   Then the exit code is 0
   When I execute dnf with args "module install postgresql:11/client"
   Then the exit code is 0
   When I execute dnf with args "module list"
   Then the exit code is 0
    And stdout contains "Javascript runtime"
    And module list is
        | Repository                    | Name          | Stream    | Profiles                      |
        | dnf-ci-fedora-modular         | nodejs        | 8 [e]     | development, minimal [i], default |
        | dnf-ci-fedora-modular         | nodejs        | 10        | development, minimal, default |
        | dnf-ci-fedora-modular         | postgresql    | 9.6       | client, server, default       |
        | dnf-ci-fedora-modular         | meson         | master    | default                       |
        | dnf-ci-fedora-modular         | ninja         | master    | default                       |
        | dnf-ci-fedora-modular-updates | nodejs        | 8 [e]     | development, minimal [i], default |
        | dnf-ci-fedora-modular-updates | nodejs        | 10        | development, minimal, default |
        | dnf-ci-fedora-modular-updates | nodejs        | 11        | development, minimal, default |
        | dnf-ci-fedora-modular-updates | postgresql    | 9.6       | client, server, default       |
        | dnf-ci-fedora-modular-updates | postgresql    | 10        | client, server, default       |
        | dnf-ci-fedora-modular-updates | postgresql    | 11 [e]    | client [i], server, default       |


Scenario: I can list enabled modules
   When I execute dnf with args "module list --enabled"
   Then the exit code is 0
    And module list is
        | Repository                    | Name          | Stream    | Profiles                      |
        | dnf-ci-fedora-modular         | nodejs        | 8 [e]     | development, minimal [i], default |
        | dnf-ci-fedora-modular-updates | nodejs        | 8 [e]     | development, minimal [i], default |
        | dnf-ci-fedora-modular-updates | postgresql    | 11 [e]    | client [i], server, default       |


Scenario: I can list installed modules
   When I execute dnf with args "module list --installed"
   Then the exit code is 0
    And module list is
        | Repository                    | Name          | Stream    | Profiles                      |
        | dnf-ci-fedora-modular         | nodejs        | 8 [e]     | development, minimal [i], default |
        | dnf-ci-fedora-modular-updates | nodejs        | 8 [e]     | development, minimal [i], default |
        | dnf-ci-fedora-modular-updates | postgresql    | 11 [e]    | client [i], server, default       |


@bz1647382
Scenario: I can list disabled modules (when there are no disabled modules)
   When I execute dnf with args "module list --disabled"
   Then the exit code is 0
    And stderr contains "No matching Modules to list"


Scenario: I can list disabled modules
   When I execute dnf with args "module disable postgresql"
   Then the exit code is 0
   When I execute dnf with args "module list --disabled"
   Then the exit code is 0
    And module list is
        | Repository                    | Name          | Stream    | Profiles                      |
        | dnf-ci-fedora-modular         | postgresql    | 9.6 [x]   | client, server, default       |
        | dnf-ci-fedora-modular-updates | postgresql    | 9.6 [x]   | client, server, default       |
        | dnf-ci-fedora-modular-updates | postgresql    | 10 [x]    | client, server, default       |
        | dnf-ci-fedora-modular-updates | postgresql    | 11 [x]    | client, server, default       |


Scenario: I can limit the scope through providing specific module names
   When I execute dnf with args "module list nodejs"
   Then the exit code is 0
    And module list is
        | Repository                    | Name          | Stream    | Profiles                      |
        | dnf-ci-fedora-modular         | nodejs        | 8 [e]     | development, minimal [i], default |
        | dnf-ci-fedora-modular         | nodejs        | 10        | development, minimal, default |
        | dnf-ci-fedora-modular-updates | nodejs        | 8 [e]     | development, minimal [i], default |
        | dnf-ci-fedora-modular-updates | nodejs        | 10        | development, minimal, default |
        | dnf-ci-fedora-modular-updates | nodejs        | 11        | development, minimal, default |


Scenario: I can limit the scope of enabled modules through providing specific module names
   When I execute dnf with args "module list --enabled nodejs"
   Then the exit code is 0
    And module list is
        | Repository                    | Name          | Stream    | Profiles                      |
        | dnf-ci-fedora-modular         | nodejs        | 8 [e]     | development, minimal [i], default |
        | dnf-ci-fedora-modular-updates | nodejs        | 8 [e]     | development, minimal [i], default |


Scenario: I can limit the scope of installed modules through providing specific module names
   When I execute dnf with args "module list --installed nodejs"
   Then the exit code is 0
    And module list is
        | Repository                    | Name          | Stream    | Profiles                      |
        | dnf-ci-fedora-modular         | nodejs        | 8 [e]     | development, minimal [i], default |
        | dnf-ci-fedora-modular-updates | nodejs        | 8 [e]     | development, minimal [i], default |


Scenario: I can limit the scope of disabled modules through providing specific module names
   When I execute dnf with args "module list --disabled postgresql nodejs"
   Then the exit code is 0
    And module list is
        | Repository                    | Name          | Stream    | Profiles                      |
        | dnf-ci-fedora-modular         | postgresql    | 9.6 [x]   | client, server, default       |
        | dnf-ci-fedora-modular-updates | postgresql    | 9.6 [x]   | client, server, default       |
        | dnf-ci-fedora-modular-updates | postgresql    | 10 [x]    | client, server, default       |
        | dnf-ci-fedora-modular-updates | postgresql    | 11 [x]    | client, server, default       |


