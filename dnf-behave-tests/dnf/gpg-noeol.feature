@dnf5daemon
@dnf5
Feature: Testing gpg signed packages by keys without any EOL characters at EOF

# Masterkey signed packages in repository dnf-ci-gpg-noeol:
#     abcde
#     wget

Background: Add repository with gpgcheck=1
  Given I use repository "dnf-ci-gpg-noeol" with configuration
        | key      | value                                                                                  |
        | gpgcheck | 1                                                                                      |
        | gpgkey   | file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg-noeol/dnf-ci-gpg-noeol-public |
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "dnf-ci-gpg-noeol\s+dnf-ci-gpg-noeol"
      # At the start of each test, there are no imported gpg keys in RPM DB
   When I execute rpm with args "-q gpg-pubkey"
   Then the exit code is 1


# the scenario is failing with rpm on Fedora 30:
# rpm --import gpgkeys/keys/dnf-ci-gpg-noeol/dnf-ci-gpg-noeol-public
# error: gpgkeys/keys/dnf-ci-gpg-noeol/dnf-ci-gpg-noeol-public: key 1 not an armored public key.
@use.with_os=rhel__ge__8
@bz1733971
Scenario: Import the GPG key without any EOL characters at EOF
   When I execute rpm with args "--import {context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg-noeol/dnf-ci-gpg-noeol-public"
   Then the exit code is 0


Scenario: Install signed package from repository
   When I execute dnf with args "install abcde"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                     |
        | install       | abcde-0:2.9.2-1.fc29.noarch |
        | install-dep   | wget-0:1.19.5-5.fc29.x86_64 |

