Feature: Better counting

    @fixture.osrelease
    @fixture.httpd
    Scenario: User-Agent header is sent
        Given I am running a system identified as the "Fedora 29 server"
          And I am using libdnf of the version X.Y.Z
          And I have enabled a remote repository
         When I refresh the metadata
         Then every HTTP request to the repository should contain:
            | header     | value                                          |
            | User-Agent | libdnf/X.Y.Z (Fedora 29; server; Linux.x86_64) |

    @fixture.osrelease
    @fixture.httpd
    Scenario: User-Agent header is sent (generic variant)
        Given I am running a system identified as the "Fedora 30"
          And I am using libdnf of the version X.Y.Z
          And I have enabled a remote repository
         When I refresh the metadata
         Then every HTTP request to the repository should contain:
            | header     | value                                  |
            | User-Agent | libdnf/X.Y.Z (Fedora 30; generic; Linux.x86_64) |

    @fixture.httpd
    Scenario: System gets counted for the first time
        Given my system has not been counted yet
          And I have enabled a remote repository with metalink support
          And the repository has the "countme" option set to "1"
         When I execute dnf with args "countme"
         Then exactly one HTTP request for the metalink should contain:
            | URL parameter | value |
            | countme       | 1     |
