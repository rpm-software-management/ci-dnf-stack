Feature: DNF SSL related features - Package installation

  Scenario: Installing a package from https repository
      Given https repository "TestRepoA" with packages
         | Package | Tag | Value |
         | TestA   |     |       |
         | TestB   |     |       |
         | TestC   |     |       |
        And a repo file of repository "TestRepoA" modified with
         | Key       | Value |
         | sslverify | True  |
       When I save rpmdb
        And I enable repository "TestRepoA"
        And I successfully run "dnf -y install TestA"
       Then rpmdb changes are
         | State     | Packages |
         | installed | TestA    |

  @backup
  Scenario: Backup /etc/httpd/conf.d/ssl.conf
       Given I successfully run "cp -p /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.testbackup"

  Scenario: Installing a package from https repository with client verification
       When I successfully run "sed -i 's/.*SSLVerifyClient.*/SSLVerifyClient require/' /etc/httpd/conf.d/ssl.conf"
        And I successfully run "httpd -k restart"
        And I save rpmdb
        And I successfully run "dnf -y install TestB"
       Then rpmdb changes are
         | State     | Packages |
         | installed | TestB    |

  Scenario: Instaling a package using untrusted client cert should fail
      Given a repo file of repository "TestRepoA" modified with
         | Key           | Value                                         |
         | sslclientkey  | /etc/pki/tls/certs/testcerts/client2/key.pem  |
         | sslclientcert | /etc/pki/tls/certs/testcerts/client2/cert.pem |
       When I run "dnf -v -y install TestC"
       Then the command should fail
        And the command stdout should match regexp "Cannot download repomd.xml"

  @restore
  Scenario: Restore httpd setting
      Given I successfully run "mv /etc/httpd/conf.d/ssl.conf.testbackup /etc/httpd/conf.d/ssl.conf"
        And I successfully run "httpd -k restart"
