Feature: SSL related tests


@fixture.httpd
Scenario: Installing a package from https repository
  Given I use the https repository based on "dnf-ci-fedora"
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "https-dnf-ci-fedora\s+https-dnf-ci-fedora"
   When I execute dnf with args "install filesystem -v"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


@fixture.httpd
Scenario: Installing a package from https repository with client verification
  Given I require client certificate verification with certificate "certificates/testcerts/client/cert.pem" and key "certificates/testcerts/client/key.pem"
    And I use the https repository based on "dnf-ci-fedora"
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "https-dnf-ci-fedora\s+https-dnf-ci-fedora"
   When I execute dnf with args "install filesystem -v"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


@fixture.httpd
Scenario: Instaling a package using untrusted client cert should fail
  Given I require client certificate verification with certificate "certificates/testcerts/client2/cert.pem" and key "certificates/testcerts/client2/key.pem"
    And I use the https repository based on "dnf-ci-fedora"
   When I execute dnf with args "install filesystem -v"
   Then the exit code is 1
    And stdout contains "Cannot download repomd\.xml"
