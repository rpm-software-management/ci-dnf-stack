@dnf5
Feature: Remove old versions of installonly packages


Background: Setup test repositories
  Given I use repository "dnf-ci-fedora"


Scenario: Remove old versions of ALL installonly packages keeping only newest
  Given I set config option "installonly_limit" to "3"
   When I execute dnf with args "install kernel-core"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | unchanged     | kernel-core-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.20.6-300.fc29.x86_64  |
        | unchanged     | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | unchanged     | kernel-core-0:4.18.16-300.fc29.x86_64 |
   When I execute dnf with args "remove --oldinstallonly --limit=2"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | unchanged     | kernel-core-0:4.20.6-300.fc29.x86_64  |
        | unchanged     | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | remove        | kernel-core-0:4.18.16-300.fc29.x86_64 |


Scenario: Remove old versions keeping only 2 newest with package filter
  Given I use repository "installonly"
    And I set config option "installonly_limit" to "3"
   When I execute dnf with args "install kernel-core-4.18.16"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64 |
   When I execute dnf with args "install kernel-core-4.19.15"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.19.15-300.fc29.x86_64 |
   When I execute dnf with args "install kernel-core-4.20.6"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.20.6-300.fc29.x86_64  |
   When I execute dnf with args "remove --oldinstallonly --limit=2 kernel-core"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | unchanged     | kernel-core-0:4.20.6-300.fc29.x86_64  |
        | unchanged     | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | remove        | kernel-core-0:4.18.16-300.fc29.x86_64 |


Scenario: Remove old versions of multiple specific installonly packages
  Given I use repository "installonly"
    And I configure dnf with
        | key             | value        |
        | installonlypkgs | installonlyA |
    And I set config option "installonly_limit" to "3"
   When I execute dnf with args "install kernel-core-4.18.16 installonlyA-1.0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64 |
        | install       | installonlyA-0:1.0-1.x86_64           |
   When I execute dnf with args "install kernel-core-4.19.15 installonlyA-2.0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | install       | installonlyA-0:2.0-1.x86_64           |
   When I execute dnf with args "install kernel-core-4.20.6 installonlyA-2.2"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.20.6-300.fc29.x86_64  |
        | install       | installonlyA-0:2.2-1.x86_64           |
   When I execute dnf with args "remove --oldinstallonly --limit=2 kernel-core installonlyA"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | unchanged     | kernel-core-0:4.20.6-300.fc29.x86_64  |
        | unchanged     | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | remove        | kernel-core-0:4.18.16-300.fc29.x86_64 |
        | unchanged     | installonlyA-0:2.2-1.x86_64           |
        | unchanged     | installonlyA-0:2.0-1.x86_64           |
        | remove        | installonlyA-0:1.0-1.x86_64           |


Scenario: Works with glob patterns
  Given I use repository "installonly"
    And I set config option "installonly_limit" to "3"
   When I execute dnf with args "install kernel-core-4.18.16"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64 |
   When I execute dnf with args "install kernel-core-4.19.15"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.19.15-300.fc29.x86_64 |
   When I execute dnf with args "install kernel-core-4.20.6"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.20.6-300.fc29.x86_64  |
   When I execute dnf with args "remove --oldinstallonly --limit=2 'kernel*'"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | unchanged     | kernel-core-0:4.20.6-300.fc29.x86_64  |
        | unchanged     | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | remove        | kernel-core-0:4.18.16-300.fc29.x86_64 |


Scenario: Custom limit with --oldinstallonly
  Given I use repository "installonly"
    And I set config option "installonly_limit" to "3"
   When I execute dnf with args "install kernel-core-4.18.16"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64 |
   When I execute dnf with args "install kernel-core-4.19.15"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.19.15-300.fc29.x86_64 |
   When I execute dnf with args "install kernel-core-4.20.6"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.20.6-300.fc29.x86_64  |
   When I execute dnf with args "remove --oldinstallonly --limit=2 kernel-core"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | unchanged     | kernel-core-0:4.20.6-300.fc29.x86_64  |
        | unchanged     | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | remove        | kernel-core-0:4.18.16-300.fc29.x86_64 |


Scenario: Remove old installonly packages respecting configured limit
  Given I use repository "dnf-ci-fedora"
    And I set config option "installonly_limit" to "2"
   When I execute dnf with args "install kernel-core"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | unchanged     | kernel-core-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.20.6-300.fc29.x86_64  |
        | remove        | kernel-core-0:4.18.16-300.fc29.x86_64 |
    And package state is
        | package                             | reason | from_repo                     |
        | kernel-core-4.19.15-300.fc29.x86_64 | User   | dnf-ci-fedora-updates         |
        | kernel-core-4.20.6-300.fc29.x86_64  | User   | dnf-ci-fedora-updates-testing |
   When I execute dnf with args "remove --oldinstallonly"
   Then the exit code is 0
    And Transaction is empty


@no_installroot
@destructive
Scenario: Running kernel protection prevents removal
  Given I use repository "dnf-ci-fedora"
    And I fake kernel release to "4.18.16-300.fc29.x86_64"
    And I set config option "installonly_limit" to "3"
   When I execute dnf with args "install kernel-core --repofrompath=r,{context.dnf.repos[dnf-ci-fedora].path} --repo=r --nogpgcheck"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade --repofrompath=r,{context.dnf.repos[dnf-ci-fedora-updates].path} --repo=r --nogpgcheck kernel-core"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | unchanged     | kernel-core-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "upgrade --repofrompath=r,{context.dnf.repos[dnf-ci-fedora-updates-testing].path} --repo=r --nogpgcheck kernel-core"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.20.6-300.fc29.x86_64  |
        | unchanged     | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | unchanged     | kernel-core-0:4.18.16-300.fc29.x86_64 |
   When I execute dnf with args "remove --oldinstallonly --limit=2"
   Then the exit code is 1
    And stderr contains "The operation would result in removing of running kernel"


Scenario: Remove old installonly packages with only one installed
  Given I use repository "dnf-ci-fedora"
    And I set config option "installonly_limit" to "3"
   When I execute dnf with args "install kernel-core"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64 |
   When I execute dnf with args "remove --oldinstallonly"
   Then the exit code is 0
    And Transaction is empty


Scenario: Remove old installonly packages with no packages specified over limit
  Given I use repository "installonly"
    And I set config option "installonly_limit" to "2"
   When I execute dnf with args "install kernel-core-4.18.16"
   Then the exit code is 0
   When I execute dnf with args "install kernel-core-4.19.15"
   Then the exit code is 0
   When I execute dnf with args "install kernel-core-4.20.6"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.20.6-300.fc29.x86_64  |
        | remove        | kernel-core-0:4.18.16-300.fc29.x86_64 |
   When I execute dnf with args "remove --oldinstallonly"
   Then the exit code is 0
    And Transaction is empty


Scenario: Remove old installonly packages respecting limit
  Given I drop repository "dnf-ci-fedora"
    And I use repository "kernel"
    And I set config option "installonly_limit" to "2"
   When I execute dnf with args "install kernel-1.0.0"
   Then the exit code is 0
   When I execute dnf with args "install kernel-2.0.0"
   Then the exit code is 0
   When I execute dnf with args "install kernel-3.0.0"
   Then the exit code is 0
    And Transaction is following
        | Action     | Package                              |
        | install    | kernel-0:3.0.0-1.fc29.x86_64         |
        | install    | kernel-core-0:3.0.0-1.fc29.x86_64    |
        | install    | kernel-modules-0:3.0.0-1.fc29.x86_64 |
        | remove     | kernel-0:1.0.0-1.fc29.x86_64         |
        | remove     | kernel-core-0:1.0.0-1.fc29.x86_64    |
        | remove     | kernel-modules-0:1.0.0-1.fc29.x86_64 |
   When I execute dnf with args "install kernel-4.0.0"
   Then the exit code is 0
    And Transaction is following
        | Action     | Package                              |
        | install    | kernel-0:4.0.0-1.fc29.x86_64         |
        | install    | kernel-core-0:4.0.0-1.fc29.x86_64    |
        | install    | kernel-modules-0:4.0.0-1.fc29.x86_64 |
        | remove     | kernel-0:2.0.0-1.fc29.x86_64         |
        | remove     | kernel-core-0:2.0.0-1.fc29.x86_64    |
        | remove     | kernel-modules-0:2.0.0-1.fc29.x86_64 |
   When I execute dnf with args "remove --oldinstallonly 'kernel*'"
   Then the exit code is 0
    And Transaction is empty

