@dnf5
Feature: correctly reading multiline repo config


Scenario: multiline config for gpg works with local repo
Given I use repository "simple-base"
  And I create and substitute file "/etc/yum.repos.d/simple-base.repo" with
      """
      [simple-base]
      name=simple-base test repository
      enabled=1
      baseurl=file://{context.dnf.fixturesdir}/repos/simple-base
      gpgcheck=1
      gpgkey=file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg/dnf-ci-gpg-public
             file://{context.dnf.fixturesdir}/gpgkeys/keys/dnf-ci-gpg-subkey/dnf-ci-gpg-subkey-public
      """
 When I execute dnf with args "install dedalo-signed"
 Then the exit code is 0
  And transaction is following
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
 When I execute dnf with args "install dedalo-signed"
 Then the exit code is 0
  And transaction is following
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
 When I execute dnf with args "install dedalo-signed"
 Then the exit code is 0
  And transaction is following
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
 When I execute dnf with args "install labirinto"
 Then the exit code is 0
  And transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |
