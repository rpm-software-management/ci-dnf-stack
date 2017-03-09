Feature: Builddep

  @setup
  Scenario: Feature Setup
      Given enabled repository "available" with packages
         | Package | Tag      | Value            |
         | TestA   |          |                  |
         | TestB   |          |                  |
         | TestC   |          |                  |
         | TestD   |          |                  |
         | TestE   |          |                  |
         | TestF   | Provides | /usr/bin/TestXXX |
        And a file "/tmp/test.spec" with
            """
            Name:          test
            Version:       1
            Release:       1
            Summary:       Test

            License:       Public Domain
            URL:           http://localhost

            BuildRequires: %{?buildrequires}%{?!buildrequires:TestA}
            BuildArch:     noarch

            %description
            %{summary}.

            %prep
            %autosetup -c -D -T
            """

  Scenario: Builddep with simple dependency (spec)
       When I save rpmdb
        And I successfully run "dnf -y builddep /tmp/test.spec"
       Then rpmdb changes are
         | State     | Packages |
         | installed | TestA    |

  Scenario: Builddep with simple dependency (spec) + define
       When I save rpmdb
        And I successfully run "dnf -y builddep /tmp/test.spec --define 'buildrequires TestB'"
       Then rpmdb changes are
         | State     | Packages |
         | installed | TestB    |

  Scenario: Builddep with simple dependency (srpm)
       When I successfully run "rpmbuild -D '_srcrpmdir /tmp' -D 'buildrequires TestC' -bs /tmp/test.spec"
       When I save rpmdb
        And I successfully run "dnf -y builddep /tmp/test-1-1.src.rpm"
       Then rpmdb changes are
         | State     | Packages |
         | installed | TestC    |

  Scenario: Builddep with rich dependency
       When I save rpmdb
        And I successfully run "dnf -y builddep /tmp/test.spec --define 'buildrequires (TestD and TestE)'"
       Then rpmdb changes are
         | State     | Packages     |
         | installed | TestD, TestE |

  Scenario: Builddep with simple dependency (files-like provide)
       When I save rpmdb
        And I successfully run "dnf -y builddep /tmp/test.spec --define 'buildrequires /usr/bin/TestXXX'"
       Then rpmdb changes are
         | State     | Packages |
         | installed | TestF    |

  Scenario: Builddep with simple dependency (non-existent)
       When I run "dnf -y builddep /tmp/test.spec --define 'buildrequires TestX = 1'"
       Then the command should fail
        And the command stderr should match exactly
            """
            No matching package to install: 'TestX = 1'
            Not all dependencies satisfied
            Error: Some packages could not be found.

            """
