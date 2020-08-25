Feature: Group and environment upgrade


# comps-upgrade-1 repo:
#   A-group:
#     mandatory: A-mandatory
#     default: A-default
#     optional: A-optional
#     conditional: A-conditional-true (if dummy), A-conditional-false (if nonexistent)
#   AB-group:
#     mandatory: A-mandatory
#     default: A-default
#     optional: A-optional
#     conditional: A-conditional-true (if dummy), A-conditional-false (if nonexistent)
#   AB-environment:
#     grouplist: A-group

# comps-upgrade-2 repo:
#   A-group:
#     mandatory: A-mandatory
#     default: A-default
#     optional: A-optional
#     conditional: A-conditional-true (if dummy), A-conditional-false (if nonexistent)
#   B-group:
#     mandatory: B-mandatory
#     default: B-default
#     optional: B-optional
#     conditional: B-conditional-true (if dummy), B-conditional-false (if nonexistent)
#   AB-group:
#     mandatory: B-mandatory
#     default: B-default
#     optional: B-optional
#     conditional: B-conditional-true (if dummy), B-conditional-false (if nonexistent)
#   AB-environment:
#     grouplist: B-group


Background: Enable comps-upgrade-1 nad install dummy
  Given I use repository "comps-upgrade-1"
    And I successfully execute dnf with args "install dummy"


Scenario: Upgrade group when there are new package versions - upgrade packages
  Given I successfully execute dnf with args "group install A-group"
    And I use repository "comps-upgrade-2"
   When I execute dnf with args "group upgrade A-group"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | upgrade       | A-mandatory-0:2.0-1.x86_64         |
        | upgrade       | A-default-0:2.0-1.x86_64           |
        | upgrade       | A-conditional-true-0:2.0-1.x86_64  |
        | group-upgrade | A-group                            |


Scenario: Upgrade group when there are no new packages - nothing is installed
  Given I successfully execute dnf with args "group mark install AB-group"
   When I execute dnf with args "group upgrade AB-group"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | group-upgrade | AB-group                           |


Scenario: Upgrade group when there are new packages - install new packages
  Given I successfully execute dnf with args "group mark install AB-group"
    And I drop repository "comps-upgrade-1"
    And I use repository "comps-upgrade-2"
   When I execute dnf with args "group upgrade AB-group"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | install-group | B-mandatory-0:1.0-1.x86_64         |
        | install-group | B-default-0:1.0-1.x86_64           |
        | install-group | B-conditional-true-0:1.0-1.x86_64  |
        | group-upgrade | AB-group                           |


Scenario: Upgrade group when there are both old and new packages - install only new packages
  Given I successfully execute dnf with args "group mark install AB-group"
      # I don't drop repository comps-upgrade-1, so the comps are merged
    And I use repository "comps-upgrade-2"
   When I execute dnf with args "group upgrade AB-group"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | install-group | B-mandatory-0:1.0-1.x86_64         |
        | install-group | B-default-0:1.0-1.x86_64           |
        | install-group | B-conditional-true-0:1.0-1.x86_64  |
        | group-upgrade | AB-group                           |


Scenario: Upgrade group to new metadata and back - always install new packages
  Given I successfully execute dnf with args "group mark install AB-group"
    And I drop repository "comps-upgrade-1"
    And I use repository "comps-upgrade-2"
   When I execute dnf with args "group upgrade AB-group"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | install-group | B-mandatory-0:1.0-1.x86_64         |
        | install-group | B-default-0:1.0-1.x86_64           |
        | install-group | B-conditional-true-0:1.0-1.x86_64  |
        | group-upgrade | AB-group                           |
  Given I drop repository "comps-upgrade-2"
    And I use repository "comps-upgrade-1"
   When I execute dnf with args "group upgrade AB-group"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | install-group | A-mandatory-0:1.0-1.x86_64         |
        | install-group | A-default-0:1.0-1.x86_64           |
        | install-group | A-conditional-true-0:1.0-1.x86_64  |
        | group-upgrade | AB-group                           |


Scenario: Upgrade group when there were excluded packages during installation - don't install these packages
   When I execute dnf with args "group install AB-group --exclude=A-mandatory,A-default,A-optional,A-conditional-true"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | group-install | AB-group                           |
   When I execute dnf with args "group upgrade AB-group"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | group-upgrade | AB-group                           |


Scenario: Upgrade group when there were removed packages since installation - don't install these packages
  Given I successfully execute dnf with args "group install AB-group"
    And I successfully execute dnf with args "remove A-mandatory A-default A-conditional-true"
   When I execute dnf with args "group upgrade AB-group"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | group-upgrade | AB-group                           |


Scenario: Upgrade environment when there are no new groups/packages - nothing is installed
  Given I successfully execute dnf with args "group mark install AB-environment"
   When I execute dnf with args "group upgrade AB-environment"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | group-upgrade | A-group                            |
        | env-upgrade   | AB-environment                     |


Scenario: Upgrade environment when there are new groups/packages - install new groups/packages
  Given I successfully execute dnf with args "group mark install AB-environment"
    And I drop repository "comps-upgrade-1"
    And I use repository "comps-upgrade-2"
   When I execute dnf with args "group upgrade AB-environment"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | install-group | B-mandatory-0:1.0-1.x86_64         |
        | install-group | B-default-0:1.0-1.x86_64           |
        | install-group | B-conditional-true-0:1.0-1.x86_64  |
        | group-install | B-group                            |
        | env-upgrade   | AB-environment                     |


Scenario: Upgrade environment when there are both old and new groups/packages - install only new groups/packages
  Given I successfully execute dnf with args "group mark install AB-environment"
      # I don't drop repository comps-environment-upgrade-1, so the comps are merged
    And I use repository "comps-upgrade-2"
   When I execute dnf with args "group upgrade AB-environment"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | install-group | B-mandatory-0:1.0-1.x86_64         |
        | install-group | B-default-0:1.0-1.x86_64           |
        | install-group | B-conditional-true-0:1.0-1.x86_64  |
        | group-upgrade | A-group                            |
        | group-install | B-group                            |
        | env-upgrade   | AB-environment                     |


Scenario: Upgrade environment to new metadata and back - always install new groups/packages
  Given I successfully execute dnf with args "group mark install AB-environment"
    And I drop repository "comps-upgrade-1"
    And I use repository "comps-upgrade-2"
   When I execute dnf with args "group upgrade AB-environment"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | install-group | B-mandatory-0:1.0-1.x86_64         |
        | install-group | B-default-0:1.0-1.x86_64           |
        | install-group | B-conditional-true-0:1.0-1.x86_64  |
        | group-install | B-group                            |
        | env-upgrade   | AB-environment                     |
  Given I drop repository "comps-upgrade-2"
    And I use repository "comps-upgrade-1"
   When I execute dnf with args "group upgrade AB-environment"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | install-group | A-mandatory-0:1.0-1.x86_64         |
        | install-group | A-default-0:1.0-1.x86_64           |
        | install-group | A-conditional-true-0:1.0-1.x86_64  |
        | group-install | A-group                            |
        | env-upgrade   | AB-environment                     |


Scenario: Upgrade environment when there were excluded packages during installation - don't install these packages
  Given I successfully execute dnf with args "group mark install AB-environment"
   When I execute dnf with args "group install AB-environment --exclude=A-mandatory,A-default,A-optional,A-conditional-true"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | group-install | A-group                            |
        | env-install   | AB-environment                     |
   When I execute dnf with args "group upgrade AB-environment"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | group-upgrade | A-group                            |
        | env-upgrade   | AB-environment                     |


Scenario: Upgrade environment when there were removed packages since installation - don't install these packages
  Given I successfully execute dnf with args "group install AB-environment"
    And I successfully execute dnf with args "remove A-mandatory A-default A-conditional-true"
   When I execute dnf with args "group upgrade AB-environment"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                            |
        | group-upgrade | A-group                            |
        | env-upgrade   | AB-environment                     |
