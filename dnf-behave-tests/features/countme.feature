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
    Scenario: User-Agent header is sent (short version)
        Given I am running a system identified as the "Fedora 30"
          And I am using libdnf of the version X.Y.Z
          And I have enabled a remote repository
         When I refresh the metadata
         Then every HTTP request to the repository should contain:
            | header     | value                                  |
            | User-Agent | libdnf/X.Y.Z (Fedora 30; Linux.x86_64) |
