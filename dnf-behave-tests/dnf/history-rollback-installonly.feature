Feature: Transaction history rollback with installonly packages


Background:
  Given I use repository "kernel"
    And I successfully execute dnf with args "install kernel-core-1.0.0"


# Several coexisting NEVRAs of an installonly package installed within a
# single transaction used to be collapsed to just the latest one when the
# transaction history was merged for rollback, so only the newest of them
# got removed.
Scenario: Rollback a single transaction that installed several coexisting EVRs
  Given I successfully execute dnf with args "install kernel-core-2.0.0 kernel-core-3.0.0"
   When I execute dnf with args "history rollback 1"
   Then the exit code is 0
    And Transaction is following
        | Action | Package                            |
        | remove | kernel-core-0:3.0.0-1.fc29.x86_64   |
        | remove | kernel-core-0:2.0.0-1.fc29.x86_64   |


# The same coexisting NEVRAs can also accumulate across several separate
# transactions being merged into one rollback - each transaction installing
# one more NEVRA alongside the ones already installed by earlier ones.
Scenario: Rollback across several transactions that each installed one more coexisting EVR
  Given I successfully execute dnf with args "install kernel-core-2.0.0"
    And I successfully execute dnf with args "install kernel-core-3.0.0"
   When I execute dnf with args "history rollback 1"
   Then the exit code is 0
    And Transaction is following
        | Action | Package                            |
        | remove | kernel-core-0:3.0.0-1.fc29.x86_64   |
        | remove | kernel-core-0:2.0.0-1.fc29.x86_64   |


# A rollback merge window can also span a Remove of an older coexisting EVR
# that predates the window - that Remove must survive the merge as its own
# entry instead of being misattributed to (and silently erasing) an
# unrelated, still-installed EVR of the same installonly package.
Scenario: Rollback restores an installonly EVR removed within the merge window
  Given I successfully execute dnf with args "install kernel-core-2.0.0"
    And I successfully execute dnf with args "remove kernel-core-1.0.0"
   When I execute dnf with args "history rollback 1"
   Then the exit code is 0
    And Transaction is following
        | Action  | Package                           |
        | remove  | kernel-core-0:2.0.0-1.fc29.x86_64 |
        | install | kernel-core-0:1.0.0-1.fc29.x86_64 |
