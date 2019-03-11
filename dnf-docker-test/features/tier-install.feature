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
