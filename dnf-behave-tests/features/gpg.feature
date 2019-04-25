Feature: Testing gpgcheck


# Signed packages in repository dnf-ci-gpg:
#     setup
#     filesystem
#     filesystem-content
#     abcde
#     broken-package
#     glibc
#     glibc-common
#     glibc-all-langpacks
# Incorrectly signed packages:
#     basesystem in dnf-ci-gpg is signed with key from dnf-ci-gpg-updates
#     basesystem in dnf-ci-gpg-updates is signed with key from dnf-ci-gpg


Background: Add repository with gpgcheck=1
  Given I use the repository "dnf-ci-gpg"
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "dnf-ci-gpg\s+dnf-ci-gpg"
      # At the start of each test, there are no imported gpg keys in RPM DB
   When I execute rpm with args "-q gpg-pubkey"
   Then the exit code is 1


Scenario: Install signed package and check GPG key was imported
   When I execute dnf with args "install setup -v"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                             |
        | install       | setup-0:2.12.1-1.fc29.noarch        |
      # There is now one imported gpg key in RPM db
      # (the braces are doubled because there is .format() used for the string)
   When I execute rpm with args "-q gpg-pubkey --qf '%{{summary}}\n'"
   Then the exit code is 0
    And stdout contains "gpg\(dnf-ci-gpg\)"


Scenario: Install signed package with signed dependency
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                             |
        | install       | setup-0:2.12.1-1.fc29.noarch        |
        | install       | filesystem-0:3.9-2.fc29.x86_64      |
   When I execute rpm with args "-q gpg-pubkey --qf '%{{summary}}\n'"
   Then the exit code is 0
    And stdout contains "gpg\(dnf-ci-gpg\)"


Scenario: Fail to install signed package with incorrectly signed dependency (with key from different repository)
   When I execute dnf with args "install glibc"
   Then the exit code is 1
    And DNF Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install       | glibc-common-0:2.28-9.fc29.x86_64         |
        | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
    And RPMDB Transaction is empty


Scenario: Fail to install signed package with incorrect checksum
   When I execute dnf with args "install broken-package -v"
   Then the exit code is 1
    And DNF Transaction is following
        | Action        | Package                               |
        | install       | broken-package-0:0.2.4-1.fc29.noarch  |
    And RPMDB Transaction is empty


Scenario: Install signed, unsigned and signed with unknown key packages from repo with gpgcheck=0 in repofile
  Given I use the repository "dnf-ci-gpg-nocheck"
    And I disable the repository "dnf-ci-gpg"
   # install signed package
   When I execute dnf with args "install setup"
   Then the exit code is 0
   # install unsigned package
   When I execute dnf with args "install flac"
   Then the exit code is 0
   # install signed with unknown key package
   When I execute dnf with args "install basesystem"
   Then the exit code is 0


Scenario: Install unsigned package from repositorory without gpgcheck set using option --nogpgcheck
  Given I disable the repository "dnf-ci-gpg"
    And I use the repository "dnf-ci-gpgcheck-undefined"
   When I execute dnf with args "install flac --nogpgcheck"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                             |
        | install       | flac-0:1.3.2-8.fc29.x86_64          |


@bz1314405
Scenario: Fail to install package with incorrect checksum when gpgcheck=0
  Given I disable the repository "dnf-ci-gpg"
    And I use the repository "dnf-ci-gpgcheck-undefined"
   When I execute dnf with args "install broken-package --nogpgcheck"
   Then the exit code is 1
    And DNF Transaction is following
        | Action        | Package                               |
        | install       | broken-package-0:0.2.4-1.fc29.noarch  |
    And RPMDB Transaction is empty
