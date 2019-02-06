Feature: Installing package from module

Background:
  Given I use the repository "dnf-ci-fedora-modular"
    And I use the repository "dnf-ci-fedora"
    And I execute dnf with args "module enable ninja:master"

Scenario: I can install a specific package from a module
   When I execute dnf with args "install ninja-build"
   Then the exit code is 0
    And Transaction contains
        | Action                    | Package                                           |
        | install                   | ninja-build-0:1.8.2-4.module_1991+4e5efe2f.x86_64 |


Scenario: I can install a package from modular repo not belonging to a module
   When I execute dnf with args "install solveigs_song"
   Then the exit code is 0
    And Transaction is following
        | Action                    | Package                           |
        | install                   | solveigs_song-0:1.0-1.x86_64      |

