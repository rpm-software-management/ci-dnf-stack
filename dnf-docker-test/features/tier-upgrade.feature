Feature: Tier tests for upgrading RPM
# RPM-UPGRADE-1:
#   Desc: I can upgrade an RPM
#   Then:
#   - The RPM MUST be upgraded on disk
#   - The RPM MUST be upgraded in the RPM Database
#   - The RPM MUST be upgraded in the DNF Software Database
#   - If there is no newer RPM, notify user about that (success)

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
      Given local repository "base-new" with packages
          | Package     | Tag       | Value             |
          | TestA       | Version   | 2                 |
          |             | Release   | 1                 |
          |             | Arch      | noarch            |
          |             | Provides  | TestA-key10 = 10  |
          | Test-pkg-B  | Version   | 2                 |
          |             | Release   | 1                 |
      Given http repository "base-http" with packages
          | Package     | Tag       | Value             |
          | TestC       | Version   | 1                 |
          |             | Release   | 1                 |
      Given http repository "base-http-new" with packages
          | Package     | Tag       | Value             |
          | TestC       | Version   | 2                 |
          |             | Release   | 1                 |
      Given ftp repository "base-ftp" with packages
          | Package     | Tag       | Value             |
          | TestD       | Version   | 1                 |
          |             | Release   | 1                 |
      Given ftp repository "base-ftp-new" with packages
          | Package     | Tag       | Value             |
          | TestD       | Version   | 2                 |
          |             | Release   | 1                 |

  Scenario: I can upgrade an RPM by $pkgspec where $pkgspec is name
  # RPM-UPGRADE-2.1: $pkgspec is name
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade TestA"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM by $pkgspec where $pkgspec is name-version
  # RPM-UPGRADE-2.2: $pkgspec is name-version
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade TestA-2"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM by $pkgspec where $pkgspec is name-version-release
  # RPM-UPGRADE-2.3: $pkgspec is name-version-release
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade TestA-2-1"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM by $pkgspec where $pkgspec is name-version-release.arch
  # RPM-UPGRADE-2.4: $pkgspec is name-version-release.arch
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade TestA-2-1.noarch"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM by $pkgspec where $pkgspec is name.arch
  # RPM-UPGRADE-2.5: $pkgspec is name.arch
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade TestA.noarch"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM by $pkgspec where $pkgspec contains name with dashes
  # RPM-UPGRADE-2.6: $pkgspec contains name with dashes
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
        And I successfully run "dnf -y install Test-pkg-B.noarch"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade Test-pkg-B.noarch"
       Then the command should pass
        And a file "/usr/local/Test-pkg-B/Test-pkg-B-2-1.tmp" exists
        And a file "/usr/local/Test-pkg-B/Test-pkg-B-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages    |
          | updated   | Test-pkg-B  |
       When I successfully run "dnf list Test-pkg-B"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^Test-pkg-B\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove Test-pkg-B"
       Then the command should pass

  Scenario: I can upgrade an RPM by $pkgspec where $pkgspec contains wildcards
  # RPM-UPGRADE-2.7: $pkgspec contains wildcards
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
        And I successfully run "dnf -y install Test-pkg-B.noarch"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade Test-*-B.noarch"
       Then the command should pass
        And a file "/usr/local/Test-pkg-B/Test-pkg-B-2-1.tmp" exists
        And a file "/usr/local/Test-pkg-B/Test-pkg-B-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages    |
          | updated   | Test-pkg-B  |
       When I successfully run "dnf list Test-pkg-B"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^Test-pkg-B\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove Test-pkg-B"
       Then the command should pass

  Scenario: I can upgrade an RPM by $provide where $provide is key
  # RPM-UPGRADE-3.1: $provide is key
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade 'TestA-key10'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM by $provide where $provide is key = value
  # RPM-UPGRADE-3.2: $provide is key = value
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade 'TestA-key10 = 10'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM by $provide where $provide is key > value
  # RPM-UPGRADE-3.3: $provide is key > value
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade 'TestA-key10 > 9'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM by $provide where $provide is key >= value
  # RPM-UPGRADE-3.4: $provide is key >= value
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade 'TestA-key10 >= 10'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM by $provide where $provide is key <= value
  # RPM-UPGRADE-3.5: $provide is key <= value
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade 'TestA-key10 <= 11'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM by $provide where $provide is key > value
  # RPM-UPGRADE-3.6: $provide is key > value
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade 'TestA-key10 > 9'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM by $file_provide where $file_provide is a file
  # RPM-UPGRADE-4.1: $file_provide is a file
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade /usr/local/TestA/TestA-2-1.tmp"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM by $file_provide where $file_provide is a directory
  # RPM-UPGRADE-4.2: $file_provide is a directory
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade /usr/local/TestA"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM by $file_provide where $file_provide contains wildcards
  # RPM-UPGRADE-4.3: $file_provide contains wildcards
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade /usr/local/TestA/TestA*.tmp"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM from $path on disk where $path is an absolute path to an RPM
  # RPM-UPGRADE-5.1: $path is an absolute path to an RPM
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        # dnf upgrade /tmp/tmppath/TestA-2-1.noarch.rpm
        And I run "sh -c 'dnf -y upgrade $(dnf repoinfo base-new | grep "^Repo-baseurl" | sed "s|.*file://\(.*\)|\1/TestA-2-1.noarch.rpm|")'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +.*$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM from $path on disk where $path is a relative path to an RPM
  # RPM-UPGRADE-5.2: $path is a relative path to an RPM
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "dnf -y upgrade TestA-2-1.noarch.rpm" in repository "base-new"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +.*$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM from $path on disk where $path contains wildcards
  # RPM-UPGRADE-5.3: $path contains wildcards
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
        And I successfully run "sh -c 'dnf -y install TestA-1*.rpm'" in repository "base"
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
       When I save rpmdb
        And I enable repository "base-new"
        And I successfully run "sh -c 'dnf -y upgrade TestA-2*.rpm'" in repository "base-new"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +.*$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade an RPM from $url where $url is a http address
  # RPM-UPGRADE-6.1: $url is a http address
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
       When I save rpmdb
        And I enable repository "base-http-new"
        # dnf upgrade http://localhost/tmppath/TestC-2-1.noarch.rpm
        And I run "sh -c 'dnf -y upgrade $(dnf repoinfo base-http-new | grep "^Repo-baseurl" | sed "s|.*: \(.*\)|\1/TestC-2-1.noarch.rpm|")'"
       Then the command should pass
        And a file "/usr/local/TestC/TestC-2-1.tmp" exists
        And a file "/usr/local/TestC/TestC-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestC     |
       When I successfully run "dnf list TestC"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestC\.noarch +2-1 +.*$
          """
       When I successfully run "dnf -y remove TestC"
       Then the command should pass

  Scenario: I can upgrade an RPM from $url where $url is a ftp address
  # RPM-UPGRADE-6.2: $url is a ftp address
       When I save rpmdb
        And I enable repository "base-ftp"
        # dnf install ftp://localhost/tmppath/TestD-1-1.noarch.rpm
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
       When I save rpmdb
        And I enable repository "base-ftp-new"
        # dnf upgrade ftp://localhost/tmppath/TestD-2-1.noarch.rpm
        And I run "sh -c 'dnf -y upgrade $(dnf repoinfo base-ftp-new | grep "^Repo-baseurl" | sed "s|.*: \(.*\)|\1/TestD-2-1.noarch.rpm|")'"
       Then the command should pass
        And a file "/usr/local/TestD/TestD-2-1.tmp" exists
        And a file "/usr/local/TestD/TestD-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestD     |
       When I successfully run "dnf list TestD"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestD\.noarch +2-1 +.*$
          """
       When I successfully run "dnf -y remove TestD"
       Then the command should pass

  Scenario: I can upgrade an RPM from $url where $url is a local path
  # RPM-UPGRADE-6.4: $url is a local path
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
        # dnf install file://localhost/tmppath/TestA-1-1.noarch.rpm
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
       When I save rpmdb
        And I enable repository "base-new"
        # dnf upgrade file://localhost/tmppath/TestA-2-1.noarch.rpm
        And I run "sh -c 'dnf -y upgrade $(dnf repoinfo base-new | grep "^Repo-baseurl" | sed "s|.*: \(.*\)|\1/TestA-2-1.noarch.rpm|")'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages  |
          | updated   | TestA     |
       When I successfully run "dnf list TestA"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +.*$
          """
       When I successfully run "dnf -y remove TestA"
       Then the command should pass

  Scenario: I can upgrade all RPMs from available repos
  # RPM-UPGRADE-7:
       When I save rpmdb
        And I enable repository "base"
        And I disable repository "base-new"
        And I enable repository "base-http"
        And I disable repository "base-http-new"
        And I enable repository "base-ftp"
        And I disable repository "base-ftp-new"
        And I successfully run "dnf -y install TestA TestC TestD"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" exists
        And a file "/usr/local/TestC/TestC-1-1.tmp" exists
        And a file "/usr/local/TestD/TestD-1-1.tmp" exists
        And rpmdb changes are
          | State     | Packages             |
          | installed | TestA, TestC, TestD  |
       When I successfully run "dnf list TestA TestC TestD"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +1-1 +@base *$
          ^TestC\.noarch +1-1 +@base-http *$
          ^TestD\.noarch +1-1 +@base-ftp *$
          """
       When I save rpmdb
        And I enable repository "base-new"
        And I enable repository "base-http-new"
        And I enable repository "base-ftp-new"
        And I successfully run "dnf -y upgrade"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-2-1.tmp" exists
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And a file "/usr/local/TestC/TestC-2-1.tmp" exists
        And a file "/usr/local/TestC/TestC-1-1.tmp" does not exist
        And a file "/usr/local/TestD/TestD-2-1.tmp" exists
        And a file "/usr/local/TestD/TestD-1-1.tmp" does not exist
        And rpmdb changes are
          | State     | Packages             |
          | updated   | TestA, TestC, TestD  |
       When I successfully run "dnf list TestA TestC TestD"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Installed Packages.*$
          ^TestA\.noarch +2-1 +@base-new *$
          ^TestC\.noarch +2-1 +@base-http-new *$
          ^TestD\.noarch +2-1 +@base-ftp-new *$
          """
       When I successfully run "dnf -y remove TestA TestC TestD"
       Then the command should pass
