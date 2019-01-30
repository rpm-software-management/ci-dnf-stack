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
