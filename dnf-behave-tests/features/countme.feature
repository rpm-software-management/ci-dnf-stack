Feature: Better user counting

    @fixture.osrelease
    @fixture.httpd.log
    Scenario: User-Agent header is sent
        Given I am running a system identified as the "Fedora 30 server"
          And I am using libdnf of the version X.Y.Z
          And I have enabled a remote repository
         When I execute dnf with args "makecache"
         Then every HTTP GET request should match:
            | header     | value                                          |
            | User-Agent | libdnf/X.Y.Z (Fedora 30; server; Linux.x86_64) |

    @fixture.osrelease
    @fixture.httpd.log
    Scenario: User-Agent header is sent (missing variant)
        Given I am running a system identified as the "Fedora 31"
          And I am using libdnf of the version X.Y.Z
          And I have enabled a remote repository
         When I execute dnf with args "makecache"
         Then every HTTP GET request should match:
            | header     | value                                           |
            | User-Agent | libdnf/X.Y.Z (Fedora 31; generic; Linux.x86_64) |

    @fixture.osrelease
    @fixture.httpd.log
    Scenario: User-Agent header is sent (unknown variant)
        Given I am running a system identified as the "Fedora 31 myspin"
          And I am using libdnf of the version X.Y.Z
          And I have enabled a remote repository
         When I execute dnf with args "makecache"
         Then every HTTP GET request should match:
            | header     | value                                           |
            | User-Agent | libdnf/X.Y.Z (Fedora 31; generic; Linux.x86_64) |

    @fixture.osrelease
    @fixture.httpd.log
    Scenario: Shortened User-Agent value on a non-Fedora system
        Given I am running a system identified as the "OpenSUSE 15.1 desktop"
          And I am using libdnf of the version X.Y.Z
          And I have enabled a remote repository
         When I execute dnf with args "makecache"
         Then every HTTP GET request should match:
            | header     | value        |
            | User-Agent | libdnf/X.Y.Z |

    @fixture.httpd.log
    Scenario: Custom User-Agent value
        Given I have enabled a remote repository
          And I set config option "user_agent" to "'Agent 007'"
         When I execute dnf with args "makecache"
         Then every HTTP GET request should match:
            | header     | value     |
            | User-Agent | Agent 007 |
