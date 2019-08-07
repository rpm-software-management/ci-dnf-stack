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

    @fixture.httpd.log
    Scenario: Countme flag is sent once per week
        Given I set config option "countme" to "1"
          And today is Wednesday, August 07, 2019
          And I have enabled a remote metalink repository
          # The countme feature only activates when refreshing the metalink so
          # we need one first.
          And I execute dnf with args "makecache"
         # One in the first 4 requests is randomly chosen to include the flag
         # (see COUNTME_BUDGET=4 in libdnf/repo/Repo.cpp for details)
         When I execute dnf with args "check-update --refresh" 4 times
         Then exactly one metalink request should include the countme flag
         # Same week
         When today is Friday, August 09, 2019
          And I execute dnf with args "check-update --refresh" 4 times
         Then no metalink request should include the countme flag
         # Next week
         When today is Tuesday, August 13, 2019
          And I execute dnf with args "check-update --refresh" 4 times
         Then exactly one metalink request should include the countme flag

    @fixture.httpd.log
    Scenario: Countme feature is disabled
        Given I set config option "countme" to "0"
          And I have enabled a remote metalink repository
          And I execute dnf with args "makecache"
         When I execute dnf with args "check-update --refresh" 4 times
         Then no metalink request should include the countme flag
