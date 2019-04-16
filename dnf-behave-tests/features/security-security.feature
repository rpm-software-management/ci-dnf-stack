Feature: Test security options for update


Background: Use repository with advisories
  Given I use the repository "dnf-ci-security"
   When I execute dnf with args "install security_A-1.0-1 security_B-1.0-1"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                   |
        | install       | security_A-0:1.0-1.x86_64 |
        | install       | security_B-0:1.0-1.x86_64 |


Scenario: Security check-update when there are no such updates
  Given I disable the repository "dnf-ci-security"
    And I use the repository "dnf-ci-fedora"
   When I execute dnf with args "check-update --security"
   Then the exit code is 0
    And stdout does not contain "security_A"
    And stdout does not contain "security_B"


Scenario: Security check-update when there are such updates
   When I execute dnf with args "check-update --security"
   Then the exit code is 100
    And stdout contains "security_A.*1\.0-4\s+dnf-ci-security"
    And stdout does not contain "security_B"


Scenario Outline: Security <command>
   When I execute dnf with args "<command> --security"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                   |
        | upgrade       | <package>                 |

Examples:
    | command           | package                   |
    | update            | security_A-0:1.0-4.x86_64 |
    | upgrade           | security_A-0:1.0-4.x86_64 |
    | update-minimal    | security_A-0:1.0-3.x86_64 |
    | upgrade-minimal   | security_A-0:1.0-3.x86_64 |


# depends on backporting of https://github.com/rpm-software-management/dnf/commit/6c45861ad7f5e6a6d586025a05c39b4b7a180aa0
@not.with_os=rhel__eq__8
Scenario Outline: Security <command> with bzs explicitly mentioned
   When I execute dnf with args "<command> --security --bz 123 --bzs=234,345"
   Then the exit code is 0
    And Transaction contains
        | Action        | Package                   |
        | upgrade       | <package>                 |

Examples:
    | command           | package                   |
    | update            | security_A-0:1.0-4.x86_64 |
    | update-minimal    | security_A-0:1.0-4.x86_64 |
