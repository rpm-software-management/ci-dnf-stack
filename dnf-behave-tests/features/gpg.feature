Feature: Testing gpgcheck


# Masterkey signed packages in repository dnf-ci-gpg:
#     setup
#     abcde
#     broken-package
#     glibc
#     glibc-common
#     glibc-all-langpacks
# Subkey signed packages in repository dnf-ci-gpg:
#     filesystem
#     filesystem-content
# Incorrectly signed packages:
#     basesystem in dnf-ci-gpg is signed with key from dnf-ci-gpg-updates
#     basesystem in dnf-ci-gpg-updates is signed with key from dnf-ci-gpg


Background: Add repository with gpgcheck=1
  Given I use repository "dnf-ci-gpg" with configuration
        | key      | value                                                                                                                                                               |
        | gpgcheck | 1                                                                                                                                                                   |
        | gpgkey   | file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg/dnf-ci-gpg-public,file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg-subkey/dnf-ci-gpg-subkey-public |
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "dnf-ci-gpg\s+dnf-ci-gpg"
      # At the start of each test, there are no imported gpg keys in RPM DB
   When I execute rpm with args "-q gpg-pubkey"
   Then the exit code is 1


Scenario: Install masterkey signed package and check GPG key was imported
   When I execute dnf with args "install setup -v"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                             |
        | install       | setup-0:2.12.1-1.fc29.noarch        |
      # There is now one imported gpg key in RPM db
      # (the braces are doubled because there is .format() used for the string)
   When I execute rpm with args "-q gpg-pubkey --qf 'gpg(%{{packager}})\n'"
   Then the exit code is 0
    And stdout contains "gpg\(dnf-ci-gpg\)"


Scenario: Install subkey signed package with masterkey signed dependency
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                             |
        | install       | filesystem-0:3.9-2.fc29.x86_64      |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch        |
   When I execute rpm with args "-q gpg-pubkey --qf 'gpg(%{{packager}})\n'"
   Then the exit code is 0
    And stdout contains "gpg\(dnf-ci-gpg\)"
    And stdout contains "gpg\(dnf-ci-gpg-subkey\)"


Scenario: Fail to install signed package with incorrectly signed dependency (with key from different repository)
   When I execute dnf with args "install glibc"
   Then the exit code is 1
    And DNF Transaction is following
        | Action        | Package                                   |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64            |
        | install-dep   | basesystem-0:11-6.fc29.noarch             |
        | install-dep   | glibc-common-0:2.28-9.fc29.x86_64         |
        | install-dep   | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
    And RPMDB Transaction is empty


Scenario: Fail to install signed package with incorrect checksum
   When I execute dnf with args "install broken-package -v"
   Then the exit code is 1
    And DNF Transaction is following
        | Action        | Package                               |
        | install       | broken-package-0:0.2.4-1.fc29.noarch  |
    And RPMDB Transaction is empty


Scenario: Install masterkey signed, unsigned and masterkey signed with unknown key packages from repo with gpgcheck=0 in repofile
  Given I configure repository "dnf-ci-gpg" with
        | key      | value                                                                      |
        | gpgcheck | 0                                                                          |
        | gpgkey   | file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg/dnf-ci-gpg-public |
   # install masterkey signed package
   When I execute dnf with args "install setup"
   Then the exit code is 0
   # install unsigned package
   When I execute dnf with args "install flac"
   Then the exit code is 0
   # install master signed with unknown key package
   When I execute dnf with args "install basesystem"
   Then the exit code is 0


Scenario: Install unsigned package from repository without gpgcheck set using option --nogpgcheck
  Given I configure repository "dnf-ci-gpg" with
        | key      | value |
        | gpgcheck |       |
        | gpgkey   |       |
   When I execute dnf with args "install flac --nogpgcheck"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                             |
        | install       | flac-0:1.3.2-8.fc29.x86_64          |


@bz1314405
Scenario: Fail to install package with incorrect checksum when gpgcheck=0
  Given I configure repository "dnf-ci-gpg" with
        | key      | value |
        | gpgcheck |       |
        | gpgkey   |       |
   When I execute dnf with args "install broken-package --nogpgcheck"
   Then the exit code is 1
    And DNF Transaction is following
        | Action        | Package                               |
        | install       | broken-package-0:0.2.4-1.fc29.noarch  |
    And RPMDB Transaction is empty

