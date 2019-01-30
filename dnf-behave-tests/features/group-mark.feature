Feature: Testing group mark

# DNF-CI-Testgroup structure:
#   mandatory: filesystem (requires setup)
#   default: lame (requires lame-libs)
#   optional: flac
#   conditional: wget, requires filesystem-content

Scenario: Mark group as installed
  Given I use the repository "dnf-ci-thirdparty"
    And I use the repository "dnf-ci-fedora"
   When I execute dnf with args "group list DNF-CI-Testgroup"
   Then the exit code is 0
    And stdout contains "Available Groups"
    And stdout contains "DNF-CI-Testgroup"
    And stdout does not contain "Installed Groups"
   When I execute dnf with args "group mark install DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | absent        | setup-0:2.12.1-1.fc29.noarch      |
        | absent        | filesystem-0:3.9-2.fc29.x86_64    |
        | absent        | lame-0:3.100-4.fc29.x86_64        |
        | absent        | lame-libs-0:3.100-4.fc29.x86_64   |
        | group-install | DNF-CI-Testgroup                  |
   When I execute dnf with args "group list DNF-CI-Testgroup"
   Then the exit code is 0
    And stdout does not contain "Available Groups"
    And stdout contains "DNF-CI-Testgroup"
    And stdout contains "Installed Groups"


Scenario: unMark group as installed
  Given I use the repository "dnf-ci-thirdparty"
    And I use the repository "dnf-ci-fedora"
   When I execute dnf with args "group mark install DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | absent        | setup-0:2.12.1-1.fc29.noarch      |
        | absent        | filesystem-0:3.9-2.fc29.x86_64    |
        | absent        | lame-0:3.100-4.fc29.x86_64        |
        | absent        | lame-libs-0:3.100-4.fc29.x86_64   |
        | group-install | DNF-CI-Testgroup                  |
   When I execute dnf with args "group list DNF-CI-Testgroup"
   Then the exit code is 0
    And stdout does not contain "Available Groups"
    And stdout contains "DNF-CI-Testgroup"
    And stdout contains "Installed Groups"
   When I execute dnf with args "group mark remove DNF-CI-Testgroup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | absent        | setup-0:2.12.1-1.fc29.noarch      |
        | absent        | filesystem-0:3.9-2.fc29.x86_64    |
        | absent        | lame-0:3.100-4.fc29.x86_64        |
        | absent        | lame-libs-0:3.100-4.fc29.x86_64   |
        | group-remove  | DNF-CI-Testgroup                  |
   When I execute dnf with args "group list DNF-CI-Testgroup"
   Then the exit code is 0
    And stdout contains "Available Groups"
    And stdout contains "DNF-CI-Testgroup"
    And stdout does not contain "Installed Groups"
