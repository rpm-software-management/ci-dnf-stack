Feature: Remove RPMs by pkgspec


Background: Installs 3 kernel versions and other packages 
  Given I use repository "installonly"
    # "/usr" directory is needed to load rpm database (to overcome bad heuristics in libdnf created by Colin Walters)
    And I create directory "/usr"
   When I execute microdnf with args "install kernel-4.18.16 kernel-4.19.15 kernel-4.20.6 installonlyA-2.0 installonlyB-2.0"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                |
        | install       | installonlyA-0:2.0-1.x86_64            |
        | install       | installonlyB-0:2.0-1.x86_64            |
        | install       | kernel-0:4.18.16-300.fc29.x86_64       |
        | install       | kernel-0:4.19.15-300.fc29.x86_64       |
        | install       | kernel-0:4.20.6-300.fc29.x86_64        |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64  |
        | install       | kernel-core-0:4.19.15-300.fc29.x86_64  |
        | install       | kernel-core-0:4.20.6-300.fc29.x86_64   |


Scenario: Remove an RPM by name
   When I execute microdnf with args "remove installonlyA"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                |
        | remove        | installonlyA-0:2.0-1.x86_64            |


Scenario: Remove multiple RPMs by name
   When I execute microdnf with args "remove kernel"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                |
        | remove        | kernel-0:4.18.16-300.fc29.x86_64       |
        | remove        | kernel-0:4.19.15-300.fc29.x86_64       |
        | remove        | kernel-0:4.20.6-300.fc29.x86_64        |


@bz2084602
Scenario: Remove multiple RPMs by name with globs
   When I execute microdnf with args "remove inst*only?"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                |
        | remove        | installonlyA-0:2.0-1.x86_64            |
        | remove        | installonlyB-0:2.0-1.x86_64            |


@bz2084602
Scenario Outline: Remove an RPM by <pkgspec-type>
   When I execute microdnf with args "remove <pkgspec>"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                |
        | remove        | kernel-0:4.19.15-300.fc29.x86_64       |

Examples: Other pkgspecs
  | pkgspec-type                    | pkgspec                           |
  | name-version                    | kernel-4.19.15                    |
  | name-version-release            | kernel-4.19.15-300.fc29           |
  | name-version-release.arch       | kernel-4.19.15-300.fc29.x86_64    |
  | name-epoch:version-release.arch | kernel-0:4.19.15-300.fc29.x86_64  |
  | name.arch                       | ke*e?-0:4.19.15-300.fc29.x86_64   |
  | pkgspec contining wildcards     | kerne?-0:4.19*-300.fc29.x86_64    |
