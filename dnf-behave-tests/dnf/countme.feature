Feature: Better user counting

    @destructive
    @bz1777255
    @bz1676891
    Scenario Outline: User-Agent header is sent
        Given I am running a system identified as the "<system>"
          And I use repository "dnf-ci-fedora" as http
          And I start capturing outbound HTTP requests
         When I execute dnf with args "makecache"
         Then every HTTP GET request should match:
            | header     | value   |
            | User-Agent | <agent> |

    Examples:
        | system                        | agent                                                         |
        | Fedora 29; server             | libdnf (Fedora 29; server; Linux.x86_64)                      |
        | Fedora 30; workstation        | libdnf (Fedora 30; workstation; Linux.x86_64)                 |
        | Fedora 31                     | libdnf (Fedora 31; generic; Linux.x86_64)                     |
        | Red Hat Enterprise Linux 8.1  | libdnf (Red Hat Enterprise Linux 8.1; generic; Linux.x86_64)  |
        | CentOS Linux 8.1              | libdnf (CentOS Linux 8.1; generic; Linux.x86_64)              |

    @destructive
    Scenario: No os-release file installed
        Given I remove the os-release file
          And I use repository "dnf-ci-fedora" as http
          And I start capturing outbound HTTP requests
         When I execute dnf with args "makecache"
         Then the exit code is 0
          And every HTTP GET request should match:
            | header     | value  |
            | User-Agent | libdnf |

    Scenario: Custom User-Agent value
        Given I use repository "dnf-ci-fedora" as http
          And I set config option "user_agent" to "'Agent 007'"
          And I start capturing outbound HTTP requests
         When I execute dnf with args "makecache"
         Then every HTTP GET request should match:
            | header     | value     |
            | User-Agent | Agent 007 |

    Scenario: Countme flag is sent once per calendar week
        Given I set config option "countme" to "1"
          And I copy repository "dnf-ci-fedora" for modification
          And I use repository "dnf-ci-fedora" as http
          And I set up metalink for repository "dnf-ci-fedora"
          And I start capturing outbound HTTP requests

         # First calendar week (bucket 1)
         # Note: One in the first 4 requests is randomly chosen to include the
         # flag (see COUNTME_BUDGET=4 in libdnf/repo/Repo.cpp for details)
         When today is Wednesday, August 07, 2019
         When I execute dnf with args "makecache" 4 times
         Then exactly one HTTP GET request should match:
            | path                      |
            | */metalink.xml*&countme=1 |

         # Same calendar week (should not be sent)
         When today is Friday, August 09, 2019
          And I forget any HTTP requests captured so far
          And I execute dnf with args "makecache" 4 times
         Then no HTTP GET request should match:
            | path                      |
            | */metalink.xml*&countme=* |

         # Next calendar week (bucket 1)
         When today is Tuesday, August 13, 2019
          And I forget any HTTP requests captured so far
          And I execute dnf with args "makecache" 4 times
         Then exactly one HTTP GET request should match:
            | path                      |
            | */metalink.xml*&countme=1 |

         # Next calendar week (bucket 2)
         When today is Tuesday, August 21, 2019
          And I forget any HTTP requests captured so far
          And I execute dnf with args "makecache" 4 times
         Then exactly one HTTP GET request should match:
            | path                      |
            | */metalink.xml*&countme=2 |

         # 1 calendar month later (bucket 3)
         When today is Tuesday, September 16, 2019
          And I forget any HTTP requests captured so far
          And I execute dnf with args "makecache" 4 times
         Then exactly one HTTP GET request should match:
            | path                      |
            | */metalink.xml*&countme=3 |

         # 6 calendar months later (bucket 4)
         When today is Tuesday, March 15, 2020
          And I forget any HTTP requests captured so far
          And I execute dnf with args "makecache" 4 times
         Then exactly one HTTP GET request should match:
            | path                      |
            | */metalink.xml*&countme=4 |

    Scenario: Countme flag is not sent repeatedly on retries
        Given I set config option "countme" to "1"
          And I copy repository "dnf-ci-fedora" for modification
          And I use repository "dnf-ci-fedora" as http
          And I set up metalink for repository "dnf-ci-fedora"
          # This triggers the retry mechanism in librepo, 4 retries by default
          And the server starts responding with HTTP status code 503
          And I start capturing outbound HTTP requests
         When I execute dnf with args "makecache" 4 times
         # 48 = 4 * makecache = 4 * (3 metalink attempts * 4 low-level retries)
         # See librepo commits 15adfb31 and 12d0b4ad for details
         Then exactly 48 HTTP GET requests should match:
            | path            |
            | */metalink.xml* |
          And exactly one HTTP GET request should match:
            | path                      |
            | */metalink.xml*&countme=1 |

    Scenario: Countme feature is disabled
        Given I set config option "countme" to "0"
          And I copy repository "dnf-ci-fedora" for modification
          And I use repository "dnf-ci-fedora" as http
          And I set up metalink for repository "dnf-ci-fedora"
          And I start capturing outbound HTTP requests
         When I execute dnf with args "makecache" 4 times
         Then no HTTP GET request should match:
            | path                      |
            | */metalink.xml*&countme=* |
