@global_dnf_context
Feature: Transaction history userinstalled, list and info

Background:
  Given I use the repository "dnf-ci-fedora"

Scenario: List userinstalled packages
   When I execute dnf with args "install abcde basesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | abcde-0:2.9.2-1.fc29.noarch               |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | flac-0:1.3.2-8.fc29.x86_64                |
        | install       | wget-0:1.19.5-5.fc29.x86_64               |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
   When I execute dnf with args "history userinstalled"
   Then stdout contains lines
        """
        abcde-2.9.2-1.fc29.noarch
        basesystem-11-6.fc29.noarch
        """
    But stdout does not contain lines
        """
        flac-1.3.2-8.fc29.x86_64
        wget-1.19.5-5.fc29.x86_64
        setup-2.12.1-1.fc29.noarch
        filesystem-3.9-2.fc29.x86_64
        """

Scenario: History list range
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install       | glibc-common-0:2.28-9.fc29.x86_64         |
        | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
   When I execute dnf with args "remove setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | glibc-0:2.28-9.fc29.x86_64                |
        | remove        | glibc-common-0:2.28-9.fc29.x86_64         |
        | remove        | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
        | remove        | basesystem-0:11-6.fc29.noarch             |
        | remove        | filesystem-0:3.9-2.fc29.x86_64            |
        | remove        | setup-0:2.12.1-1.fc29.noarch              |
    And History "list last-1..last" is following
        | Id     | Command       | Action        | Altered   |
        | 3      |               | Removed       | 6         |  
        | 2      |               | Install       | 3         |  
    And History "last" is following
        | Id     | Command       | Action        | Altered   |
        | 3      |               | Removed       | 6         |  


Scenario: History list package
   When I execute dnf with args "install setup"
   Then the exit code is 0
    And History "setup" is following
        | Id     | Command       | Action        | Altered   |
        | 4      |               | Install       |           |  
        | 3      |               | Removed       |           |  
        | 1      |               | Install       |           |  


Scenario: History info
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
   When I execute dnf with args "install abcde"
   Then the exit code is 0
   When I use the repository "dnf-ci-fedora-updates"
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
        | Reinstall     | abcde-2.9.2-1.fc29.noarch |
        | Reinstall     | flac-1.3.2-8.fc29.x86_64  |
        | Reinstall     | wget-1.19.5-5.fc29.x86_64 |


Scenario: History info of package
   Then History info "abcde" should match
        | Key           | Value                     |
        | Return-Code   | Success                   |
        | Install       | abcde-2.9.2-1.fc29.noarch |
        | Removed       | abcde-2.9.2-1.fc29.noarch |
        | Upgraded      | abcde-2.9.2-1.fc29.noarch |
        | Upgrade       | abcde-2.9.3-1.fc29.noarch |
