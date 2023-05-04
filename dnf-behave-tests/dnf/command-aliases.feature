Feature: Tests for command aliases availability


Scenario: "nonexistent" is not an alias for any dnf command
   When I execute dnf with args "nonexistent -h"
   Then the exit code is 1
    And stderr contains "No such command: nonexistent"


Scenario Outline: "<alias>" is an alias for "<command>"
   When I execute dnf with args "<alias> -h"
   Then the exit code is 0
    And stdout contains "usage: .* <command>"
    And stdout does not contain "No such command"
    And stderr does not contain "No such command"

Examples:
        | command             | alias                        |
        | alias               | alias                        |
        | autoremove          | autoremove                   |
        | autoremove          | autoremove-n                 |
        | autoremove          | autoremove-na                |
        | autoremove          | autoremove-nevra             |
        | check               | check                        |
        | check-update        | check-update                 |
        | check-update        | check-upgrade                |
        | clean               | clean                        |
        | deplist             | deplist                      |
        | distro-sync         | distro-sync                  |
        | distro-sync         | distrosync                   |
        | distro-sync         | distribution-synchronization |
        | distro-sync         | dsync                        |
        | downgrade           | downgrade                    |
        | downgrade           | dg                           |
        | group               | group                        |
        | group               | groups                       |
        | group               | grp                          |
        | group               | grouplist                    |
        | group               | groupinstall                 |
        | group               | groupupdate                  |
        | group               | groupremove                  |
        | group               | grouperase                   |
        | group               | groupinfo                    |
        | help                | help                         |
        | history             | history                      |
        | history             | hist                         |
        | info                | info                         |
        | install             | install                      |
        | install             | localinstall                 |
        | install             | in                           |
        | install             | install-n                    |
        | install             | install-na                   |
        | install             | install-nevra                |
        | list                | list                         |
        | makecache           | makecache                    |
        | makecache           | mc                           |
        | mark                | mark                         |
        | module              | module                       |
        | provides            | provides                     |
        | provides            | whatprovides                 |
        | provides            | prov                         |
        | reinstall           | reinstall                    |
        | reinstall           | rei                          |
        | remove              | remove                       |
        | remove              | erase                        |
        | remove              | rm                           |
        | remove              | remove-n                     |
        | remove              | remove-na                    |
        | remove              | remove-nevra                 |
        | remove              | erase-n                      |
        | remove              | erase-na                     |
        | remove              | erase-nevra                  |
        | repolist            | repolist                     |
        | repolist            | repoinfo                     |
        | repoquery           | rq                           |
        | repoquery           | repoquery                    |
        | repoquery           | repoquery-n                  |
        | repoquery           | repoquery-na                 |
        | repoquery           | repoquery-nevra              |
        | repository-packages | repository-packages          |
        | repository-packages | repo-pkgs                    |
        | repository-packages | repo-packages                |
        | repository-packages | repository-pkgs              |
        | search              | search                       |
        | shell               | shell                        |
        | shell               | sh                           |
        | swap                | swap                         |
        | updateinfo          | updateinfo                   |
        | updateinfo          | list-updateinfo              |
        | updateinfo          | list-security                |
        | updateinfo          | list-sec                     |
        | updateinfo          | info-updateinfo              |
        | updateinfo          | info-security                |
        | updateinfo          | info-sec                     |
        | updateinfo          | summary-updateinfo           |
        | upgrade             | upgrade                      |
        | upgrade             | update                       |
        | upgrade             | upgrade-to                   |
        | upgrade             | update-to                    |
        | upgrade             | localupdate                  |
        | upgrade             | up                           |
        | upgrade-minimal     | upgrade-minimal              |
        | upgrade-minimal     | update-minimal               |
        | upgrade-minimal     | up-min                       |

@dnf5
Scenario Outline: "<alias>" is not an alias for "<command>"
   When I execute dnf with args "<alias>"
   Then the exit code is 2
    And stderr contains "Unknown argument \"<alias>\" for command "

Examples:
        | command             | alias                        |
        | search              | se                           |
