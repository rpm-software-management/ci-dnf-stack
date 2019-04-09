Feature: Module profile removal


Background:
Given I use the repository "dnf-ci-fedora-modular"
  And I use the repository "dnf-ci-fedora"
 When I execute dnf with args "module enable nodejs:8"
 Then the exit code is 0
  And modules state is following
      | Module    | State     | Stream    | Profiles  |
      | nodejs    | enabled   | 8         |           |
 When I execute dnf with args "module install nodejs/default"
 Then the exit code is 0
  And Transaction contains
      | Action                    | Package                                       |
      | install                   | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | install                   | npm-1:8.11.4-1.module_2030+42747d40.x86_64    |
      | module-profile-install    | nodejs/default                                |


# https://bugzilla.redhat.com/show_bug.cgi?id=1581609
@skip-RHEL8
@bz1581609
@bz1583596
Scenario: I can remove an installed module profile specifying stream name
 When I execute dnf with args "module remove nodejs:8"
 Then the exit code is 0
  And modules state is following
      | Module    | State     | Stream    | Profiles  |
      | nodejs    | enabled   | 8         |           |
  And modules state is following
      | Module    | State     | Stream    | Profiles  |
      | nodejs    | enabled   | 8         |           |
  And Transaction contains
      | Action                    | Package                                       |
      | remove                    | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | remove                    | npm-1:8.11.4-1.module_2030+42747d40.x86_64    |
      | module-profile-disable    | nodejs/default                                |


# https://bugzilla.redhat.com/show_bug.cgi?id=1581621
# https://bugzilla.redhat.com/show_bug.cgi?id=1629841
@skip-RHEL8
@bz1583596
@bz1629841 @bz1581624
Scenario: I can remove an installed module profile using "module remove <module_spec>"
 When I execute dnf with args "module install nodejs/minimal"
 Then Transaction contains
      | Action                    | Package                                       |
      | unchanged                 | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | module-profile-install    | nodejs/minimal                                |
 When I execute dnf with args "module install nodejs/development"
 Then Transaction contains
      | Action                    | Package                                             |
      | install                   | nodejs-devel-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | module-profile-install    | nodejs/development                                  |
 When I execute dnf with args "module remove nodejs/minimal"
 Then the exit code is 0
 Then Transaction is following
      | Action                    | Package                                             |
      | unchanged                 | nodejs-devel-1:8.11.4-1.module_2030+42747d40.x86_64 |
      # cannot remove nodejs because it's needed by other profiles
      | unchanged                 | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | module-profile-disable    | nodejs/minimal                                      |
  And modules state is following
      | Module    | State     | Stream    | Profiles             |
      | nodejs    | enabled   | 8         | default, development |


@bz1629848
Scenario: Removing of a non-installed profiles would pass
 When I execute dnf with args "module remove nodejs/development"
 Then the exit code is 0
 Then Transaction is empty
  And modules state is following
      | Module    | State     | Stream    | Profiles  |
      | nodejs    | enabled   | 8         | default   |
  And modules state is following
      | Module    | State     | Stream    | Profiles |
      | nodejs    | enabled   | 8         | default  |
  And stdout contains "Nothing to do."
  And stderr contains "Unable to match profile in argument nodejs/development"


@skip-RHEL8
@bz1583596
Scenario: I can remove multiple profiles
 When I execute dnf with args "module install nodejs/minimal"
 Then Transaction contains
      | Action                    | Package                                       |
      | unchanged                 | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | module-profile-install    | nodejs/minimal                                |
 When I execute dnf with args "module install nodejs/development"
 Then Transaction contains
      | Action                    | Package                                             |
      | install                   | nodejs-devel-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | module-profile-install    | nodejs/development                                  |
  And modules state is following
      | Module    | State     | Stream    | Profiles                      |
      | nodejs    | enabled   | 8         | default, minimal, development |
 When I execute dnf with args "module remove nodejs/development nodejs:8/default"
 Then Transaction is following
      | Action                 | Package                                             |
      | remove                 | nodejs-devel-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | module-profile-disable | nodejs/default                                      |
      | module-profile-disable | nodejs/development                                  |
  And modules state is following
      | Module    | State     | Stream    | Profiles  |
      | nodejs    | enabled   | 8         | minimal   |


# https://bugzilla.redhat.com/show_bug.cgi?id=1648264
@skip-RHEL8
@bz1583596
@bz1648264
Scenario: I can remove an installed module profile using "remove @<module_spec>"
 When I execute dnf with args "module install nodejs/minimal"
 Then Transaction contains
      | Action                    | Package                                       |
      | unchanged                 | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | module-profile-install    | nodejs/minimal                                |
 When I execute dnf with args "module install nodejs/development"
 Then Transaction contains
      | Action                    | Package                                             |
      | install                   | nodejs-devel-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | module-profile-install    | nodejs/development                                  |
 When I execute dnf with args "remove @nodejs/minimal"
 Then the exit code is 0
 Then Transaction is following
      | Action                    | Package                                             |
      | unchanged                 | nodejs-devel-1:8.11.4-1.module_2030+42747d40.x86_64 |
      # cannot remove nodejs because it's needed by other profiles
      | unchanged                 | nodejs-1:8.11.4-1.module_2030+42747d40.x86_64 |
      | module-profile-disable    | nodejs/minimal                                      |
  And modules state is following
      | Module    | State     | Stream    | Profiles             |
      | nodejs    | enabled   | 8         | default, development |
