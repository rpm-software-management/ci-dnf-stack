Feature: Testing gpgcheck_policy option

# The gpgcheck_policy option (global, [main] section only) controls how
# setting gpgcheck=1 expands to set related GPG checking options:
#   legacy: gpgcheck=1 sets pkg_gpgcheck=1
#   full:   gpgcheck=1 sets pkg_gpgcheck=1 and repo_gpgcheck=1
#   all:    gpgcheck=1 sets pkg_gpgcheck=1, repo_gpgcheck=1, localpkg_gpgcheck=1
#
# Explicitly set options in the same config section override the expansion.
# At the repository level, only pkg_gpgcheck and repo_gpgcheck are affected
# (localpkg_gpgcheck is a main config only option).
#
# simple-base packages are signed by "default-key" which is imported at test start.
# unsigned repo packages are intentionally unsigned.


Scenario: Legacy policy with gpgcheck=1 enables only pkg_gpgcheck
  Given I configure dnf with
        | key              | value  |
        | gpgcheck         | 0      |
        | gpgcheck_policy  | legacy |
    And I use repository "simple-base" with configuration
        | key          | value                                                                        |
        | gpgcheck     | 1                                                                            |
        | pkg_gpgcheck |                                                                              |
        | gpgkey       | file://{context.dnf.fixturesdir}/gpgkeys/keys/default-key/default-key-public |
   # Repo metadata is not signed, but legacy policy does not enforce repo_gpgcheck
   When I execute dnf with args "install labirinto"
   Then the exit code is 0
    And Transaction is following
        | Action  | Package                       |
        | install | labirinto-0:1.0-1.fc29.x86_64 |


Scenario: Full policy with gpgcheck=1 and signed metadata succeeds
  Given I configure dnf with
        | key              | value |
        | gpgcheck         | 0     |
        | gpgcheck_policy  | full  |
    And I copy repository "simple-base" for modification
    And I sign repository "simple-base" metadata with "{context.dnf.fixturesdir}/gpgkeys/keys/default-key/default-key-private"
    And I use repository "simple-base" with configuration
        | key          | value                                                                        |
        | gpgcheck     | 1                                                                            |
        | pkg_gpgcheck |                                                                              |
        | gpgkey       | file://{context.dnf.fixturesdir}/gpgkeys/keys/default-key/default-key-public |
   When I execute dnf with args "install labirinto"
   Then the exit code is 0
    And Transaction is following
        | Action  | Package                       |
        | install | labirinto-0:1.0-1.fc29.x86_64 |


Scenario: Full policy with gpgcheck=1 and unsigned metadata fails
  Given I configure dnf with
        | key              | value |
        | gpgcheck         | 0     |
        | gpgcheck_policy  | full  |
    And I use repository "simple-base" with configuration
        | key          | value                                                                        |
        | gpgcheck     | 1                                                                            |
        | pkg_gpgcheck |                                                                              |
        | gpgkey       | file://{context.dnf.fixturesdir}/gpgkeys/keys/default-key/default-key-public |
   # Full policy enforces repo_gpgcheck, but repo metadata is not signed
   When I execute dnf with args "install labirinto"
   Then the exit code is 1
    And stderr contains "GPG verification is enabled, but GPG signature is not available"


Scenario: Explicit repo_gpgcheck=0 overrides full policy
  Given I configure dnf with
        | key              | value |
        | gpgcheck         | 0     |
        | gpgcheck_policy  | full  |
    And I use repository "simple-base" with configuration
        | key           | value                                                                        |
        | gpgcheck      | 1                                                                            |
        | pkg_gpgcheck  |                                                                              |
        | repo_gpgcheck | 0                                                                            |
        | gpgkey        | file://{context.dnf.fixturesdir}/gpgkeys/keys/default-key/default-key-public |
   # Explicit repo_gpgcheck=0 overrides the full policy expansion
   When I execute dnf with args "install labirinto"
   Then the exit code is 0
    And Transaction is following
        | Action  | Package                       |
        | install | labirinto-0:1.0-1.fc29.x86_64 |


Scenario: Explicit pkg_gpgcheck=0 overrides policy and allows unsigned packages
  Given I configure dnf with
        | key              | value  |
        | gpgcheck         | 0      |
        | gpgcheck_policy  | legacy |
    And I use repository "unsigned" with configuration
        | key          | value |
        | gpgcheck     | 1     |
        | pkg_gpgcheck | 0     |
   # Policy would expand gpgcheck=1 to pkg_gpgcheck=1,
   # but explicit pkg_gpgcheck=0 overrides, allowing unsigned packages
   When I execute dnf with args "install sarcina"
   Then the exit code is 0
    And Transaction is following
        | Action  | Package                     |
        | install | sarcina-0:1.0-1.fc29.x86_64 |


Scenario: gpgcheck=0 disables all checks regardless of policy
  Given I configure dnf with
        | key              | value |
        | gpgcheck         | 0     |
        | gpgcheck_policy  | all   |
    And I use repository "unsigned" with configuration
        | key          | value |
        | gpgcheck     | 0     |
        | pkg_gpgcheck |       |
   # gpgcheck=0 with "all" policy expands to pkg_gpgcheck=0 and repo_gpgcheck=0
   When I execute dnf with args "install sarcina"
   Then the exit code is 0
    And Transaction is following
        | Action  | Package                     |
        | install | sarcina-0:1.0-1.fc29.x86_64 |


Scenario: Legacy policy fails to install unsigned packages (pkg_gpgcheck is enforced)
  Given I configure dnf with
        | key              | value  |
        | gpgcheck         | 0      |
        | gpgcheck_policy  | legacy |
    And I use repository "unsigned" with configuration
        | key          | value |
        | gpgcheck     | 1     |
        | pkg_gpgcheck |       |
   # Legacy policy expands gpgcheck=1 to pkg_gpgcheck=1, which rejects unsigned packages
   When I execute dnf with args "install sarcina"
   Then the exit code is 1
    And stderr contains "The package is not signed"
