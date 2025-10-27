Feature: SSL related tests


# @dnf5
# TODO(nsella) Unknown argument "-v" for command "install"
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
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |


# @dnf5
# TODO(nsella) Unknown argument "-v" for command "install"
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
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |


# @dnf5
# TODO(nsella) different stderr
@bz1605187
@bz1713627
Scenario: Installing a package using untrusted client cert should fail
  Given I require client certificate verification with certificate "certificates/testcerts/client2/cert.pem" and key "certificates/testcerts/client2/key.pem"
    And I use repository "dnf-ci-fedora" as https
   When I execute dnf with args "install filesystem"
   Then the exit code is 1
        # The list of errors sometimes contains additional errors to the one tested below:
        #   - Curl error (55): Failed sending data to the peer for https://localhost:37237/repodata/repomd.xml [SSL_write() returned SYSCALL, errno = 104]
        #   - Curl error (55): Failed sending data to the peer for https://localhost:38661/repodata/repomd.xml [SSL_write() returned SYSCALL, errno = 32]
        #   - Curl error (56): Failure when receiving data from the peer for https://localhost:37237/repodata/repomd.xml [SSL_write() returned SYSCALL, errno = 32]
        #   - Curl error (56): Failure when receiving data from the peer for https://localhost:[0-9]+/repodata/repomd.xml [OpenSSL SSL_read: error:14094418:SSL routines:ssl3_read_bytes:tlsv1 alert unknown ca, errno 0]"
        #
        # It is nondeterministic, quite rare and the cause is unknown, as well
        # as whether it is an issue with the testing framework or a bug in the
        # DNF stack. This most likely happens for all SSL connections, but is
        # mostly hidden, because librepo does four download attempts and this
        # error typically occurs two or three times (when it happens at all).
        #
        # The connection failures will be hard to debug, untill then, we test
        # for stderr containing the expected output and ignore the superfluous
        # errors.
    And stderr contains "Errors during downloading metadata for repository 'dnf-ci-fedora':"
    And stderr contains "  - Curl error"
    And stderr contains "Error: Failed to download metadata for repo 'dnf-ci-fedora': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried"


# @dnf5
# TODO(nsella) different stderr
@bz1605187
@bz1713627
Scenario: Installing a package using nonexistent client cert should fail
  Given I require client certificate verification with certificate "certificates/testcerts/nonexistent.pem" and key "certificates/testcerts/nonexistent.pem"
    And I use repository "dnf-ci-fedora" as https
   When I execute dnf with args "install filesystem"
   Then the exit code is 1
    And stderr matches line by line
    """
    Errors during downloading metadata for repository 'dnf-ci-fedora':
      - Curl error \(58\): Problem with the local SSL certificate for https://localhost:[0-9]+/repodata/repomd.xml \[could not load PEM client certificate from .*/nonexistent.pem, OpenSSL error error:[0-9]+:system library:.*:No such file or directory, \(no key found, wrong pass phrase, or wrong file format\?\)\]
    Error: Failed to download metadata for repo 'dnf-ci-fedora': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
    """


# @dnf5
# TODO(nsella) different stderr
Scenario: Installation with untrusted repository should fail
        # https repositories use sslcacert certificates/testcerts/ca/cert.pem
  Given I use repository "simple-base" as https
    And I configure repository "simple-base" with
        | key               | value |
        # replace cacert with another
        | sslcacert         | {context.dnf.fixturesdir}/certificates/testcerts/ca2/cert.pem |
   When I execute dnf with args "install labirinto"
   Then the exit code is 1
    And stderr matches line by line
    """
    Errors during downloading metadata for repository 'simple-base':
      - Curl error \(60\): .* for https://localhost:[0-9]+/repodata/repomd\.xml \[SSL certificate (OpenSSL verify result|problem):.*\]
    Error: Failed to download metadata for repo 'simple-base': Cannot download repomd\.xml: Cannot download repodata/repomd\.xml: All mirrors were tried
    """


# @dnf5
# TODO(nsella) different stderr
Scenario: Untrusted cert can be overriden with sslverify=False
  Given I use repository "simple-base" as https
    And I configure repository "simple-base" with
        | key               | value |
        | sslcacert         | {context.dnf.fixturesdir}/certificates/testcerts/ca2/cert.pem |
        | sslverify         | false |
   When I execute dnf with args "install labirinto"
   Then the exit code is 0
