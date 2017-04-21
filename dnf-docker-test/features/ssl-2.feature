Feature: DNF SSL related features - certificate verification

  @setup
  Scenario: Setup
      Given https repository "TestRepoA" with packages
         | Package | Tag | Value |
         | TestA   |     |       |
        And a repo file of repository "TestRepoA" modified with
         | Key       | Value |
         | sslverify | True  |

  Scenario: Installation with untrusted repository should fail
      Given a repo file of repository "TestRepoA" modified with
         | Key       | Value                                     |
         | sslcacert | /etc/pki/tls/certs/testcerts/ca2/cert.pem |
       When I enable repository "TestRepoA"
        And I run "dnf -v -y install TestA"
       Then the command should fail
        And the command stdout should match regexp "Cannot download repomd.xml"

  Scenario: Untrusted cert can be overriden with sslverify=False
      Given a repo file of repository "TestRepoA" modified with
         | Key       | Value |
         | sslverify | False |
       When I save rpmdb
        And I successfully run "dnf -y install TestA"
       Then rpmdb changes are
         | State     | Packages |
         | installed | TestA    |
