Feature: Advisory aplicability on a modular system


Background:
Given I use the repository "dnf-ci-fedora-modular"
  And I use the repository "dnf-ci-fedora"


@bz1622614
Scenario: List available updates for installed streams (updates available)
 When I execute dnf with args "module enable postgresql:9.6"
 Then the exit code is 0
  And modules state is following
      | Module     | State     | Stream    | Profiles  |
      | postgresql | enabled   | 9.6       |           |
 When I execute dnf with args "module install postgresql/default"
 Then the exit code is 0
  And Transaction contains
      | Action                    | Package                                                 |
      | install                   | postgresql-0:9.6.8-1.module_1710+b535a823.x86_64        |
      | install                   | postgresql-libs-0:9.6.8-1.module_1710+b535a823.x86_64   |
      | install                   | postgresql-server-0:9.6.8-1.module_1710+b535a823.x86_64 |
      | module-profile-install    | postgresql/default                                      |
Given I use the repository "dnf-ci-fedora-modular-updates"
 When I execute dnf with args "updateinfo --list"
 Then the exit code is 0
  And stdout contains "FEDORA-2019-0329090518 enhancement postgresql-9.6.11-1.x86_64"


# This scenario is failing on upstream, but should pass on latest RHEL8
@xfail
@bz1622614
Scenario: Updates for non enabled streams are hidden
 When I execute dnf with args "module install postgresql:6/default"
 Then the exit code is 0
  And Transaction contains
      | Action                    | Package                                               |
      | install                   | postgresql-0:6.1-1.module_2514+aa9aadc5.x86_64        |
      | install                   | postgresql-server-0:6.1-1.module_2514+aa9aadc5.x86_64 |
      | install                   | postgresql-libs-0:6.1-1.module_2514+aa9aadc5.x86_64   |
      | module-profile-install    | postgresql/default                                    |
Given I use the repository "dnf-ci-fedora-modular-updates"
 Then I execute dnf with args "updateinfo --list"
 Then the exit code is 0
  And stdout does not contain "FEDORA-2019-0329090518 enhancement postgresql-9.6.11-1.x86_64"
