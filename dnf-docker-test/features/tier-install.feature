Feature: Tier tests for installing RPM
# RPM-INSTALL-1:
#   Desc: I can install an RPM
#   Then:
#   - The RPM MUST be installed on disk
#   - The RPM MUST appear in the RPM Database
#   - The RPM MUST appear in the DNF Software Database

  @setup
  Scenario: Feature Setup
      Given local repository "base" with packages
          | Package     | Tag       | Value             |
          | TestA       | Version   | 1                 |
          |             | Release   | 1                 |
          |             | Arch      | noarch            |
          |             | Provides  | TestA-key10 = 10  |
          | Test-pkg-B  | Version   | 1                 |
          |             | Release   | 1                 |
      Given http repository "base-http" with packages
          | Package     | Tag       | Value             |
          | TestC       | Version   | 1                 |
          |             | Release   | 1                 |
      Given ftp repository "base-ftp" with packages
          | Package     | Tag       | Value             |
          | TestD       | Version   | 1                 |
          |             | Release   | 1                 |

  Scenario: I can install an RPM by $pkgspec where $pkgspec is name
  # RPM-INSTALL-2.1: $pkgspec is name
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $pkgspec where $pkgspec is name-version
  # RPM-INSTALL-2.2: $pkgspec is name-version
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-1"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $pkgspec where $pkgspec is name-version-release
  # RPM-INSTALL-2.3: $pkgspec is name-version-release
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-1-1"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $pkgspec where $pkgspec is name-version-release.arch
  # RPM-INSTALL-2.4: $pkgspec is name-version-release.arch
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-1-1.noarch"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $pkgspec where $pkgspec is name.arch
  # RPM-INSTALL-2.5: $pkgspec is name.arch
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA.noarch"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $pkgspec where $pkgspec contains name with dashes
  # RPM-INSTALL-2.6: $pkgspec contains name with dashes
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install Test-pkg-B-1-1"
       Then the command should pass
        And a file "/usr/local/Test-pkg-B/Test-pkg-B-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages    |
          | installed | Test-pkg-B  |
       When I successfully run "dnf list Test-pkg-B"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^Test-pkg-B\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove Test-pkg-B"
       Then the command should pass

  Scenario: I can install an RPM by $pkgspec where $pkgspec contains wildcards
  # RPM-INSTALL-2.7: $pkgspec contains wildcards
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install Test-*-B-1-1"
       Then the command should pass
        And a file "/usr/local/Test-pkg-B/Test-pkg-B-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages    |
          | installed | Test-pkg-B  |
       When I successfully run "dnf list Test-pkg-B"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^Test-pkg-B\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove Test-pkg-B"
       Then the command should pass

  Scenario: I can install an RPM by $provide where $provide is key
  # RPM-INSTALL-3.1: $provide is key
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-key10"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $provide where $provide is key
  # RPM-INSTALL-3.1: $provide is key
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-key10"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $provide where $provide is key = value
  # RPM-INSTALL-3.2: $provide is key = value
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf -y install 'TestA-key10 = 11'"
       Then the command exit code is 1
        And I successfully run "dnf -y install 'TestA-key10 = 10'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $provide where $provide is key > value
  # RPM-INSTALL-3.3: $provide is key > value
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf -y install 'TestA-key10 > 10'"
       Then the command exit code is 1
        And I successfully run "dnf -y install 'TestA-key10 > 9'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $provide where $provide is key >= value
  # RPM-INSTALL-3.4: $provide is key >= value
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf -y install 'TestA-key10 >= 11'"
       Then the command exit code is 1
        And I successfully run "dnf -y install 'TestA-key10 >= 10'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $provide where $provide is key <= value
  # RPM-INSTALL-3.5: $provide is key <= value
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf -y install 'TestA-key10 <= 9'"
       Then the command exit code is 1
        And I successfully run "dnf -y install 'TestA-key10 <= 10'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $provide where $provide is key < value
  # RPM-INSTALL-3.6: $provide is key < value
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf -y install 'TestA-key10 < 10'"
       Then the command exit code is 1
        And I successfully run "dnf -y install 'TestA-key10 < 11'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $file_provide where $file_provide is a file
  # RPM-INSTALL-4.1: $file_provide is a file
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install /usr/local/TestA/TestA-1-1.tmp"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $file_provide where $file_provide is a directory
  # RPM-INSTALL-4.2: $file_provide is a directory
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install /usr/local/TestA"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM by $file_provide where $file_provide contains wildcards
  # RPM-INSTALL-4.3: $file_provide contains wildcards
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install /usr/local/TestA/TestA\*.tmp"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM from $path on disk where $path is an absolute path to an RPM
  # RPM-INSTALL-5.1: $path is an absolute path to an RPM
       When I save rpmdb
        And I enable repository "base"
        # dnf install /tmp/tmppath/TestA-1-1.noarch.rpm
        And I run "sh -c 'dnf -y install $(dnf repoinfo base | grep "^Repo-baseurl" | sed "s|.*file://\(.*\)|\1/TestA-1-1.noarch.rpm|")'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +.*$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM from $path on disk where $path is a relative path to an RPM
  # RPM-INSTALL-5.2: $path is a relative path to an RPM
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-1-1.noarch.rpm" in repository "base"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +.*$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM from $path on disk where $path contains wildcards
  # RPM-INSTALL-5.3: $path contains wildcards
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "sh -c 'dnf -y install TestA*.rpm'" in repository "base"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +.*$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can install an RPM from $url where $url is a http address
  # RPM-INSTALL-6.1: $url is a http address
       When I save rpmdb
        And I enable repository "base-http"
        # dnf install http://localhost/tmppath/TestC-1-1.noarch.rpm
        And I run "sh -c 'dnf -y install $(dnf repoinfo base-http | grep "^Repo-baseurl" | sed "s|.*: \(.*\)|\1/TestC-1-1.noarch.rpm|")'"
       Then the command should pass
        And a file "/usr/local/TestC/TestC-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestC     |
       When I successfully run "dnf list TestC"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestC\.noarch +1-1 +.*$
          """
       When I successfully run "dnf -y remove TestC"
       Then the command should pass

  Scenario: I can install an RPM from $url where $url is a ftp address
  # RPM-INSTALL-6.2: $url is a ftp address
       When I save rpmdb
        And I enable repository "base-ftp"
        # dnf install ftp://localhost/pub/tmppath/TestD-1-1.noarch.rpm
        And I run "sh -c 'dnf -y install $(dnf repoinfo base-ftp | grep "^Repo-baseurl" | sed "s|.*: \(.*\)|\1/TestD-1-1.noarch.rpm|")'"
       Then the command should pass
        And a file "/usr/local/TestD/TestD-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestD     |
       When I successfully run "dnf list TestD"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestD\.noarch +1-1 +.*$
          """
       When I successfully run "dnf -y remove TestD"
       Then the command should pass

  Scenario: I can install an RPM from $url where $url is local path
  # RPM-INSTALL-6.4: $url is a local path
       When I save rpmdb
        And I enable repository "base"
        # dnf install file:///tmp/tmppath/TestA-1-1.noarch.rpm
        And I run "sh -c 'dnf -y install $(dnf repoinfo base | grep "^Repo-baseurl" | sed "s|.*: \(.*\)|\1/TestA-1-1.noarch.rpm|")'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +.*$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

