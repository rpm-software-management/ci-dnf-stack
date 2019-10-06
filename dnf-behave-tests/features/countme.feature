Feature: Better user counting

    @xfail
    @fixture.osrelease
    @fixture.httpd
    Scenario: User-Agent header is sent
        Given I am running a system identified as the "Fedora 30 server"
          And I am using libdnf of the version X.Y.Z
          And I use repository "dnf-ci-fedora" as http
          And I start capturing outbound HTTP requests
         When I execute dnf with args "makecache"
         Then every HTTP GET request should match:
            | header     | value                                          |
            | User-Agent | libdnf/X.Y.Z (Fedora 30; server; Linux.x86_64) |

    @xfail
    @fixture.osrelease
    @fixture.httpd
    Scenario: User-Agent header is sent (missing variant)
        Given I am running a system identified as the "Fedora 31"
          And I am using libdnf of the version X.Y.Z
          And I use repository "dnf-ci-fedora" as http
          And I start capturing outbound HTTP requests
         When I execute dnf with args "makecache"
         Then every HTTP GET request should match:
            | header     | value                                           |
            | User-Agent | libdnf/X.Y.Z (Fedora 31; generic; Linux.x86_64) |

    @xfail
    @fixture.osrelease
    @fixture.httpd
    Scenario: User-Agent header is sent (unknown variant)
        Given I am running a system identified as the "Fedora 31 myspin"
          And I am using libdnf of the version X.Y.Z
          And I use repository "dnf-ci-fedora" as http
          And I start capturing outbound HTTP requests
         When I execute dnf with args "makecache"
         Then every HTTP GET request should match:
            | header     | value                                           |
            | User-Agent | libdnf/X.Y.Z (Fedora 31; generic; Linux.x86_64) |

    @xfail
    @fixture.osrelease
    @fixture.httpd
    Scenario: Shortened User-Agent value on a non-Fedora system
        Given I am running a system identified as the "OpenSUSE 15.1 desktop"
          And I am using libdnf of the version X.Y.Z
          And I use repository "dnf-ci-fedora" as http
          And I start capturing outbound HTTP requests
         When I execute dnf with args "makecache"
         Then every HTTP GET request should match:
            | header     | value        |
            | User-Agent | libdnf/X.Y.Z |

    @fixture.osrelease
    @fixture.httpd
    Scenario: No os-release file installed
        Given I remove the os-release file
          And I am using libdnf of the version X.Y.Z
          And I use repository "dnf-ci-fedora" as http
          And I start capturing outbound HTTP requests
         When I execute dnf with args "makecache"
         Then the exit code is 0
          And every HTTP GET request should match:
            | header     | value        |
            | User-Agent | libdnf/X.Y.Z |

    @fixture.httpd
    Scenario: Custom User-Agent value
        Given I use repository "dnf-ci-fedora" as http
          And I set config option "user_agent" to "'Agent 007'"
          And I start capturing outbound HTTP requests
         When I execute dnf with args "makecache"
         Then every HTTP GET request should match:
            | header     | value     |
            | User-Agent | Agent 007 |

    @fixture.httpd
    Scenario: Countme flag is sent once per week
        Given I set config option "countme" to "1"
          And today is Wednesday, August 07, 2019
          And I copy repository "dnf-ci-fedora" for modification
          And I use repository "dnf-ci-fedora" as http
          And I set up metalink for repository "dnf-ci-fedora"
          And I start capturing outbound HTTP requests
         # One in the first 4 requests is randomly chosen to include the flag
         # (see COUNTME_BUDGET=4 in libdnf/repo/Repo.cpp for details)
         When I execute dnf with args "makecache" 4 times
         Then exactly one HTTP GET request should match:
            | path                     |
            | */metalink.xml?countme=1 |
         # Same week
         When today is Friday, August 09, 2019
          And I forget any HTTP requests captured so far
          And I execute dnf with args "makecache" 4 times
         Then no HTTP GET request should match:
            | path                     |
            | */metalink.xml?countme=1 |
         # Next week
         When today is Tuesday, August 13, 2019
          And I forget any HTTP requests captured so far
          And I execute dnf with args "makecache" 4 times
         Then exactly one HTTP GET request should match:
            | path                     |
            | */metalink.xml?countme=1 |

    @fixture.httpd
    Scenario: Countme feature is disabled
        Given I set config option "countme" to "0"
          And I copy repository "dnf-ci-fedora" for modification
          And I use repository "dnf-ci-fedora" as http
          And I set up metalink for repository "dnf-ci-fedora"
          And I start capturing outbound HTTP requests
         When I execute dnf with args "makecache" 4 times
         Then no HTTP GET request should match:
            | path                     |
            | */metalink.xml?countme=1 |
