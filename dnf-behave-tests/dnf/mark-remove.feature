@dnf5
Feature: Mark dependency

Scenario: Marking toplevel package as dependency should not remove shared dependencies on autoremove
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install nss_hesiod libnsl"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | libnsl-0:2.28-9.fc29.x86_64               |
        | install       | nss_hesiod-0:2.28-9.fc29.x86_64           |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64            |
        | install-dep   | basesystem-0:11-6.fc29.noarch             |
        | install-dep   | glibc-0:2.28-9.fc29.x86_64                |
        | install-dep   | glibc-common-0:2.28-9.fc29.x86_64         |
        | install-dep   | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
   When I execute dnf with args "mark dependency libnsl"
   Then the exit code is 0
   When I execute dnf with args "autoremove"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | libnsl-0:2.28-9.fc29.x86_64               |
