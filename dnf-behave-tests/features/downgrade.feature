Feature: Downgrade command

Scenario: Downgrade one RPM
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | flac-0:1.3.3-3.fc29.x86_64                |
   When I execute dnf with args "downgrade flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | downgrade     | flac-0:1.3.3-2.fc29.x86_64                |
   When I execute dnf with args "downgrade flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | downgrade     | flac-0:1.3.3-1.fc29.x86_64                |
   When I execute dnf with args "downgrade flac"
   Then the exit code is 1
    And stderr contains "Package flac of lowest version already installed, cannot downgrade it."

Scenario: Downgrade RPM that requires downgrade of dependency
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | glibc-0:2.28-26.fc29.x86_64               |
        | install       | glibc-common-0:2.28-26.fc29.x86_64        |
        | install       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | basesystem-0:11-6.fc29.noarch             |
   When I execute dnf with args "downgrade glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | downgrade     | glibc-0:2.28-9.fc29.x86_64                |
        | downgrade     | glibc-common-0:2.28-9.fc29.x86_64         |
        | downgrade     | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
