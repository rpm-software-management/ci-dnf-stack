Feature: libdnf context part correctly reading repo config


@xfail
Scenario: multiline config for gpg works with local repo
Given I use repository "simple-base"
  And I create and substitute file "/etc/yum.repos.d/simple-base.repo" with
      """
      [simple-base]
      name=simple-base test repository
      enabled=1
      baseurl=file:///opt/behave/fixtures/repos/simple-base
      gpgcheck=1
      gpgkey=file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg/dnf-ci-gpg-public
             file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg-subkey/dnf-ci-gpg-subkey-public
      """
 When I execute microdnf with args "install dedalo-signed"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                           |
      | install       | dedalo-signed-0:1.0-1.fc29.x86_64 |


@bz1807864
Scenario: multiline config for gpg works with remote repo
Given I use repository "simple-base" as http
  And I create and substitute file "/etc/yum.repos.d/simple-base.repo" with
      """
      [simple-base]
      name=simple-base test repository
      enabled=1
      baseurl=http://localhost:{context.dnf.ports[simple-base]}
      gpgcheck=1
      gpgkey=file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg/dnf-ci-gpg-public
             file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg-subkey/dnf-ci-gpg-subkey-public
      """
 When I execute microdnf with args "install dedalo-signed"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                           |
      | install       | dedalo-signed-0:1.0-1.fc29.x86_64 |


@bz1807864
Scenario: multiline multivalue comma and space separated config for gpg works with remote repo
Given I use repository "simple-base" as http
  And I create and substitute file "/etc/yum.repos.d/simple-base.repo" with
      """
      [simple-base]
      name=simple-base test repository
      enabled=1
      baseurl=http://localhost:{context.dnf.ports[simple-base]}
      gpgcheck=1
      gpgkey=file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg/dnf-ci-gpg-public file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg-noeol/dnf-ci-gpg-noeol-public
             file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg-subkey/dnf-ci-gpg-subkey-public, file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg-updates/dnf-ci-gpg-updates-public
      """
 When I execute microdnf with args "install dedalo-signed"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                           |
      | install       | dedalo-signed-0:1.0-1.fc29.x86_64 |


Scenario: multiline config for baseurl
Given I use repository "simple-base" as http
  And I create and substitute file "/etc/yum.repos.d/simple-base.repo" with
      """
      [simple-base]
      name=simple-base test repository
      enabled=1
      baseurl=http://invalid.url file:///also/invalid
              file:///the/last/is/valid, http://localhost:{context.dnf.ports[simple-base]}
      gpgcheck=0
      """
 When I execute microdnf with args "install labirinto"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |


@bz1797265
Scenario: install older version of available pkg from repo with higher (smaller number) priority
Given I use repository "simple-base" with configuration
      | key      | value |
      | priority | 1     |
  And I use repository "simple-updates" with configuration
      | key      | value |
      | priority | 2     |
 When I execute microdnf with args "install labirinto"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |
