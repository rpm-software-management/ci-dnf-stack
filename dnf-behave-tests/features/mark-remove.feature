Feature: Mark remove

Scenario: Marking toplevel package for removal should not remove shared dependencies
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install nss_hesiod libnsl"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install       | glibc-common-0:2.28-9.fc29.x86_64         |
        | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
        | install       | nss_hesiod-0:2.28-9.fc29.x86_64           |
        | install       | libnsl-0:2.28-9.fc29.x86_64               |
   When I execute dnf with args "mark remove libnsl"
   Then the exit code is 0
   When I execute dnf with args "autoremove"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | libnsl-0:2.28-9.fc29.x86_64               |
