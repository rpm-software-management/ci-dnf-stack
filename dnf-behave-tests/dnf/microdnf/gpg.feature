Feature: GPG signatures


@bz1915990
@bz1932079
@bz1932089
@bz1932090
Scenario: Refuse to install a package with broken gpg signature
  Given I use repository "dnf-ci-broken-rpm-signature" with configuration
        | key      | value                                                                                                                                                               |
        | gpgcheck | 1                                                                                                                                                                   |
        | gpgkey   | file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg/dnf-ci-gpg-public,file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg-subkey/dnf-ci-gpg-subkey-public |
    And I execute rpm with args "--import {context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg/dnf-ci-gpg-public"
   When I execute microdnf with args "install setup"
   Then the exit code is 1
   # microdnf must not extract any files from the broken package
   Then file "/usr/share/doc/setup/README" does not exist
