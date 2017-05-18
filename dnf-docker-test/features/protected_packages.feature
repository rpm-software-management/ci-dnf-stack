Feature: Protected packages

  @setup
  Scenario: Feature Setup
      Given repository "base" with packages
         | Package | Tag      | Value |
         | TestA   | Requires | TestB |
         | TestB   |          |       |
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA"
       Then rpmdb changes are
         | State     | Packages     |
         | installed | TestA, TestB |

  Scenario: Removal of directly protected package
       When I save rpmdb
        And I run "dnf -y remove TestA --setopt=protected_packages=TestA"
       Then the command should fail
        And the command stderr should match regexp "Problem: The operation would result in removing the following protected packages: TestA"
        And rpmdb does not change

  Scenario: Removal of indirectly protected package
       When I save rpmdb
        And I run "dnf -y remove TestB --setopt=protected_packages=TestA"
       Then the command should fail
# FIXME: Error: package TestA-1-1.fc24.noarch requires TestB, but none of the providers can be installed
#       And the command stderr should match exactly
#           """
#           Error: The operation would result in removing the following protected packages: TestA
#
#           """
        And rpmdb does not change

  Scenario: Removal of DNF itself
       When I save rpmdb
        And I run "dnf -y remove dnf"
       Then the command should fail
        And the command stderr should match regexp "Problem: The operation would result in removing the following protected packages: dnf"
        And rpmdb does not change
             
  Scenario: Removal of protected package with conffile
      Given a file "/etc/yum/protected.d/test.conf" with
            """
            TestA
            """
       When I save rpmdb
        And I run "dnf -y remove TestA"
       Then the command should fail
        And the command stderr should match regexp "Problem: The operation would result in removing the following protected packages: TestA"
        And rpmdb does not change
