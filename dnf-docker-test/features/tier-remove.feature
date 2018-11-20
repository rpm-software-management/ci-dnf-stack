Feature: Tier tests for removing RPM
# RPM-REMOVE-1:
#   Desc: I can remove an RPM
#   Then:
#   - The RPM MUST be removed from disk
#   - The RPM MUST be removed from the RPM Database
#   - The RPM MUST be removed from the DNF Software Database

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

  Scenario: I can remove an RPM by $pkgspec where $pkgspec is name
  # RPM-REMOVE-2.1: $pkgspec is name
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA"
       Then the command should pass
       When I successfully run "dnf -y remove TestA"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages  |
          | absent  | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $pkgspec where $pkgspec is name-version
  # RPM-REMOVE-2.2: $pkgspec is name-version
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-1"
       Then the command should pass
       When I successfully run "dnf -y remove TestA-1"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages  |
          | absent  | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $pkgspec where $pkgspec is name-version-release
  # RPM-REMOVE-2.3: $pkgspec is name-version-release
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-1-1"
       Then the command should pass
       When I successfully run "dnf -y remove TestA-1-1"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages  |
          | absent  | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $pkgspec where $pkgspec is name-version-release.arch
  # RPM-REMOVE-2.4: $pkgspec is name-version-release.arch
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-1-1.noarch"
       Then the command should pass
       When I successfully run "dnf -y remove TestA-1-1.noarch"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages  |
          | absent  | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $pkgspec where $pkgspec is name.arch
  # RPM-REMOVE-2.5: $pkgspec is name.arch
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA.noarch"
       Then the command should pass
       When I successfully run "dnf -y remove TestA.noarch"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages  |
          | absent  | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $pkgspec where $pkgspec contains name with dashes
  # RPM-REMOVE-2.6: $pkgspec contains name with dashes
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install Test-pkg-B"
       Then the command should pass
       When I successfully run "dnf -y remove Test-pkg-B"
       Then the command should pass
        And a file "/usr/local/TestA/Test-pkg-B-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages    |
          | absent  | Test-pkg-B  |
       When I disable repository "base"
        And I run "dnf list Test-pkg-B"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $pkgspec where $pkgspec contains wildcards
  # RPM-REMOVE-2.7: $pkgspec contains wildcards
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install Test-*-B"
       Then the command should pass
       When I successfully run "dnf -y remove Test-*-B"
       Then the command should pass
        And a file "/usr/local/TestA/Test-pkg-B-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages    |
          | absent  | Test-pkg-B  |
       When I disable repository "base"
        And I run "dnf list Test-pkg-B"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $provide where $provide is key
  # RPM-REMOVE-3.1: $provide is key
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-1-1.noarch"
       Then the command should pass
       When I successfully run "dnf -y remove TestA-key10"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages  |
          | absent  | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $provide where $provide is key = value
  # RPM-REMOVE-3.2: $provide is key = value
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-1-1.noarch"
       Then the command should pass
       When I save rpmdb
       And I successfully run "dnf -y remove 'TestA-key10 = 9'"
       Then rpmdb does not change
       When I save rpmdb
       When I successfully run "dnf -y remove 'TestA-key10 = 10'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State    | Packages  |
          | removed  | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $provide where $provide is key > value
  # RPM-REMOVE-3.3: $provide is key > value
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-1-1.noarch"
       Then the command should pass
       When I save rpmdb
       And I successfully run "dnf -y remove 'TestA-key10 > 10'"
       Then rpmdb does not change
       When I save rpmdb
       When I successfully run "dnf -y remove 'TestA-key10 > 9'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages  |
          | removed | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $provide where $provide is key >= value
  # RPM-REMOVE-3.4: $provide is key >= value
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-1-1.noarch"
       Then the command should pass
       When I save rpmdb
       And I successfully run "dnf -y remove 'TestA-key10 >= 11'"
       Then rpmdb does not change
       When I save rpmdb
       When I successfully run "dnf -y remove 'TestA-key10 >= 10'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages  |
          | removed | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $provide where $provide is key <= value
  # RPM-REMOVE-3.5: $provide is key <= value
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-1-1.noarch"
       Then the command should pass
       When I save rpmdb
       And I successfully run "dnf -y remove 'TestA-key10 <= 9'"
       Then rpmdb does not change
       When I save rpmdb
       When I successfully run "dnf -y remove 'TestA-key10 <= 10'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages  |
          | removed | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $provide where $provide is key < value
  # RPM-REMOVE-3.6: $provide is key < value
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA-1-1.noarch"
       Then the command should pass
       When I save rpmdb
       And I successfully run "dnf -y remove 'TestA-key10 < 10'"
       Then rpmdb does not change
       When I save rpmdb
       When I successfully run "dnf -y remove 'TestA-key10 < 11'"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages  |
          | removed | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $file_provide where $file_provide is a file
  # RPM-REMOVE-4.1: $file_provide is a file
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA"
       Then the command should pass
       When I successfully run "dnf -y remove /usr/local/TestA/TestA-1-1.tmp"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages  |
          | absent  | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $file_provide where $file_provide is a directory
  # RPM-REMOVE-4.2: $file_provide is a directory
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA"
       Then the command should pass
       When I successfully run "dnf -y remove /usr/local/TestA"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages  |
          | absent  | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

  Scenario: I can remove an RPM by $file_provide where $file_provide contains wildcards
  # RPM-REMOVE-4.3: $file_provide contains wildcards
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA"
       Then the command should pass
       When I successfully run "dnf -y remove /usr/local/TestA/TestA\*.tmp"
       Then the command should pass
        And a file "/usr/local/TestA/TestA-1-1.tmp" does not exist
        And rpmdb changes are
          | State   | Packages  |
          | absent  | TestA     |
       When I disable repository "base"
        And I run "dnf list TestA"
       Then the command exit code is 1
        And the command stderr should match exactly
          """
          Error: No matching Packages to list

          """

