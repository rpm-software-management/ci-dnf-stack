Feature: SSL related tests


@fixture.httpd
Scenario: Installing a package from https repository
  Given I use repository "dnf-ci-fedora" as https
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "dnf-ci-fedora\s+dnf-ci-fedora"
   When I execute dnf with args "install filesystem -v"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


@fixture.httpd
Scenario: Installing a package from https repository with client verification
  Given I require client certificate verification with certificate "certificates/testcerts/client/cert.pem" and key "certificates/testcerts/client/key.pem"
    And I use repository "dnf-ci-fedora" as https
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "dnf-ci-fedora\s+dnf-ci-fedora"
   When I execute dnf with args "install filesystem -v"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


@fixture.httpd
Scenario: Installing a package using untrusted client cert should fail
  Given I require client certificate verification with certificate "certificates/testcerts/client2/cert.pem" and key "certificates/testcerts/client2/key.pem"
    And I use repository "dnf-ci-fedora" as https
   When I execute dnf with args "install filesystem -v"
   Then the exit code is 1
    And stderr matches line by line
    """
    Errors during downloading metadata for repository 'dnf-ci-fedora':
      - Curl error \(56\): Failure when receiving data from the peer for https://localhost:[0-9]+/repodata/repomd.xml \[OpenSSL SSL_read: error:14094418:SSL routines:ssl3_read_bytes:tlsv1 alert unknown ca, errno 0\]
    Error: Failed to download metadata for repo 'dnf-ci-fedora': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
    """
