Feature: Testing dnf clean command


Scenario: Ensure that metadata are unavailable after "dnf clean all"
  Given I use the repository "dnf-ci-rich"
   When I execute dnf with args "makecache"
   Then the exit code is 0
   When I execute dnf with args "install -C cream"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | cream-0:1.0-1.x86_64                  |
   When I execute dnf with args "clean all"
   Then the exit code is 0
   When I execute dnf with args "install -C dill"
   Then the exit code is 1
    And stdout contains "No match for argument: dill"
   When I execute dnf with args "remove cream"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | remove        | cream-0:1.0-1.x86_64                  |

