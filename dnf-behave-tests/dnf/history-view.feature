Feature: Transaction history userinstalled, list and info

Background:
  Given I use repository "dnf-ci-fedora"

Scenario: List userinstalled packages
   When I execute dnf with args "install abcde basesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | abcde-0:2.9.2-1.fc29.noarch               |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64            |
        | install-dep   | wget-0:1.19.5-5.fc29.x86_64               |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
        | install-weak  | flac-0:1.3.2-8.fc29.x86_64                |
    And package reasons are
        | Package                      | Reason          |
        | abcde-2.9.2-1.fc29.noarch    | user            |
        | basesystem-11-6.fc29.noarch  | user            |
        | filesystem-3.9-2.fc29.x86_64 | dependency      |
        | flac-1.3.2-8.fc29.x86_64     | weak-dependency |
        | setup-2.12.1-1.fc29.noarch   | dependency      |
        | wget-1.19.5-5.fc29.x86_64    | dependency      |


Scenario: History info
  Given I successfully execute dnf with args "install abcde"
   When I execute dnf with args "install setup"
   Then History info should match
        | Key           | Value                         |
        | Command Line  | install setup                 |
        | Return-Code   | Success                       |
        | Install       | setup-2.12.1-1.fc29.noarch    |
   When I execute dnf with args "remove abcde"
   Then the exit code is 0
    And History info should match
        | Key           | Value                     |
        | Command Line  | remove abcde              |
        | Return-Code   | Success                   |
        | Removed       | abcde-2.9.2-1.fc29.noarch |
        | Removed       | flac-1.3.2-8.fc29.x86_64  |
        | Removed       | wget-1.19.5-5.fc29.x86_64 |


Scenario: History info in range - transaction merging
  Given I successfully execute dnf with args "install abcde"
  Given I successfully execute dnf with args "remove abcde"
  Given I successfully execute dnf with args "install abcde"
   When I use repository "dnf-ci-fedora-updates"
    And I execute dnf with args "update"
   Then the exit code is 0
    And History info should match
        | Key           | Value                     |
        | Return-Code   | Success                   |
        | Upgrade       | abcde-2.9.3-1.fc29.noarch |
        | Upgraded      | abcde-2.9.2-1.fc29.noarch |
        | Upgrade       | flac-1.3.3-3.fc29.x86_64  |
        | Upgraded      | flac-1.3.2-8.fc29.x86_64  |
        | Upgrade       | wget-1.19.6-5.fc29.x86_64 |
        | Upgraded      | wget-1.19.5-5.fc29.x86_64 |
    And History info "last-1..last" should match
        | Key           | Value                     |
        | Return-Code   | Success                   |
        | Install       | abcde-2.9.3-1.fc29.noarch |
        | Install       | flac-1.3.3-3.fc29.x86_64  |
        | Install       | wget-1.19.6-5.fc29.x86_64 |
    And History info "last-2..last" should match
        | Key           | Value                     |
        | Return-Code   | Success                   |
        | Upgraded      | abcde-2.9.2-1.fc29.noarch |
        | Upgrade       | abcde-2.9.3-1.fc29.noarch |
        | Upgraded      | flac-1.3.2-8.fc29.x86_64  |
        | Upgrade       | flac-1.3.3-3.fc29.x86_64  |
        | Upgraded      | wget-1.19.5-5.fc29.x86_64 |
        | Upgrade       | wget-1.19.6-5.fc29.x86_64 |
    And History info "last-2..last-1" should match
        | Key           | Value                     |
        | Return-Code   | Success                   |


Scenario: History info of package
  Given I successfully execute dnf with args "install abcde"
  Given I successfully execute dnf with args "remove abcde"
   Then History info "last-1" should match
        | Key           | Value                     |
        | Return-Code   | Success                   |
        | Install       | abcde-2.9.2-1.fc29.noarch |
        | Install       | flac-1.3.2-8.fc29.x86_64  |
        | Install       | wget-1.19.5-5.fc29.x86_64 |
    And History info "last" should match
        | Key           | Value                     |
        | Return-Code   | Success                   |
        | Removed       | abcde-2.9.2-1.fc29.noarch |
        | Removed       | flac-1.3.2-8.fc29.x86_64  |
        | Removed       | wget-1.19.5-5.fc29.x86_64 |


Scenario: history info aaa (nonexistent package)
   When I execute dnf with args "history info aaa"
   Then the exit code is 0
    And stdout is
        """
        No transaction which manipulates package 'aaa' was found.
        """


Scenario: history info aaa (nonexistent package)
  Given I successfully execute dnf with args "install abcde"
   When I execute dnf with args "history info aaa"
   Then the exit code is 0
    And stdout is
        """
        No transaction which manipulates package 'aaa' was found.
        """
