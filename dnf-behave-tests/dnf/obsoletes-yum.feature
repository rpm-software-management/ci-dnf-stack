@dnf5
Feature: Obsoles behavior specified by `SOLVER_FLAG_YUM_OBSOLETES` libsolv flag


# dnf-3 fails this test, it incorrectly installs the new packages
# as dependencies.
Scenario: install all obsoleters (as user installed)
  Given I use repository "obsoletes-yum"
    And I successfully execute dnf with args "install wood-1.0"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action  | Package                    |
        | install | copper-0:1.0-1.fc29.x86_64 |
        | install | iron-0:1.0-1.fc29.x86_64   |
        | upgrade | wood-0:2.0-1.fc29.x86_64   |
   When I execute dnf with args "rq --installed --qf '%{{name}} - %{{reason}}\n'"
   Then stdout is
   """
   copper - User
   iron - User
   wood - User
   """

