Feature: Test for download command, options --destdir, --resolve, --source

  @setup
  Scenario: Feature Setup
      Given http repository "base" with packages
         | Package  | Tag       | Value  |
         | TestA    | Version   |  1     |
         | TestA v2 | Requires  | TestB  |
         |          | Requires  | TestE  |
         |          | Version   |  2     |
         | TestC    | Provides  | TestB  |
         |          | Conflicts | TestD  |
         | TestD    | Provides  | TestB  |
         |          | Conflicts | TestC  |
         | TestE    |           |        |

  Scenario: dnf download (when there is no such pkg)
       When I run "dnf download TestA"
       Then the command should fail
        And the command stderr should match regexp "No package.*available"

  Scenario: dnf download --source (when there is no such pkg)
       When I run "dnf download --source TestA"
       Then the command should fail
        And the command stderr should match regexp "No package.*available"

  Scenario: dnf download (when there is such pkg)
       When I enable repository "base"
        And I successfully run "dnf download TestA"
       Then the command stdout should match regexp "TestA-2.*rpm" 
        # check that the file has been downloaded into working directory
        And I successfully run "stat TestA-2-1.noarch.rpm"
        # check that downloaded .rpm is the same as the one in the repo
        And I successfully run "bash -c 'diff TestA-2-1.noarch.rpm /var/www/html/tmp*/TestA-2-1.noarch.rpm'"

  Scenario: dnf download --source (when there is such pkg)
       When I successfully run "dnf download --source TestA"
       Then the command stdout should match regexp "TestA-2.*src.rpm" 
        # check that the file has been downloaded into working directory
        And I successfully run "stat TestA-2-1.src.rpm"
        # check that downloaded .rpm is the same as the one in the repo
        And I successfully run "bash -c 'diff TestA-2-1.src.rpm /var/www/html/tmp*-source/TestA-2-1.src.rpm'"

  # check also download --verbose, there were some problems with it 
  Scenario: dnf download --verbose (when there is such pkg)
       When I successfully run "rm -f TestA-2-1.noarch.rpm"
        And I successfully run "dnf download --verbose TestA"
       Then the command stdout should match regexp "TestA-2.*rpm" 
        And I successfully run "stat TestA-2-1.noarch.rpm"
        And I successfully run "bash -c 'diff TestA-2-1.noarch.rpm /var/www/html/tmp*/TestA-2-1.noarch.rpm'"

  Scenario: dnf download --source --verbose (when there is such pkg)
       When I successfully run "rm -f TestA-2-1.src.rpm"
        And I successfully run "dnf download --source --verbose TestA"
       Then the command stdout should match regexp "TestA-2.*src.rpm" 
        And I successfully run "stat TestA-2-1.src.rpm"
        And I successfully run "bash -c 'diff TestA-2-1.src.rpm /var/www/html/tmp*-source/TestA-2-1.src.rpm'"

  Scenario: dnf download --resolve (download also dependencies)
       When I successfully run "dnf download --resolve TestA"
       Then the command stdout should match regexp "TestC-1.*rpm" 
        And the command stdout should match regexp "TestE-1.*rpm" 
        # TestA-2 has already been downloaded, it is not downloaded again
        And the command stdout should match regexp "SKIPPED.*TestA-2"
        And I successfully run "stat TestE-1-1.noarch.rpm"
        And I successfully run "bash -c 'diff TestE-1-1.noarch.rpm /var/www/html/tmp*/TestE-1-1.noarch.rpm'"
        And I successfully run "stat TestC-1-1.noarch.rpm"
        And I successfully run "bash -c 'diff TestC-1-1.noarch.rpm /var/www/html/tmp*/TestC-1-1.noarch.rpm'"

"""
# currently fails, see bug 1571251
  Scenario: dnf download --source --resolve (download also dependencies)
       When I successfully run "dnf download --source --resolve TestA"
       Then the command stdout should match regexp "TestC-1.*src.rpm" 
        And the command stdout should match regexp "TestE-1.*src.rpm" 
        # TestA-2 has already been downloaded, it is not downloaded again
        And the command stdout should match regexp "SKIPPED.*TestA-2"
        And I successfully run "stat TestE-1-1.src.rpm"
        And I successfully run "bash -c 'diff TestE-1-1.src.rpm /var/www/html/tmp*-source/TestE-1-1.src.rpm'"
        And I successfully run "stat TestC-1-1.src.rpm"
        And I successfully run "bash -c 'diff TestC-1-1.src.rpm /var/www/html/tmp*-source/TestC-1-1.src.rpm'"
"""

  Scenario: dnf download --destdir (when there is such pkg)
       When I successfully run "mkdir -p /tmp/testrpms"
        And I successfully run "dnf download --destdir /tmp/testrpms TestA"
       Then the command stdout should match regexp "TestA-2.*rpm" 
        # check that the file has been downloaded into working directory
        And I successfully run "stat /tmp/testrpms/TestA-2-1.noarch.rpm"
        # check that downloaded .rpm is the same as the one in the repo
        And I successfully run "bash -c 'diff /tmp/testrpms/TestA-2-1.noarch.rpm /var/www/html/tmp*/TestA-2-1.noarch.rpm'"

  Scenario: dnf download --source --destdir (when there is such pkg)
       When I successfully run "dnf download --source --destdir /tmp/testrpms TestA"
       Then the command stdout should match regexp "TestA-2.*src.rpm" 
        # check that the file has been downloaded into working directory
        And I successfully run "stat /tmp/testrpms/TestA-2-1.src.rpm"
        # check that downloaded .rpm is the same as the one in the repo
        And I successfully run "bash -c 'diff /tmp/testrpms/TestA-2-1.src.rpm /var/www/html/tmp*-source/TestA-2-1.src.rpm'"

  Scenario: dnf download --destdir --verbose (when there is such pkg)
       When I successfully run "bash -c 'rm -f /tmp/testrpms/TestA*'"
        And I successfully run "dnf download --verbose --destdir /tmp/testrpms TestA"
       Then the command stdout should match regexp "TestA-2.*rpm" 
        # check that the file has been downloaded into working directory
        And I successfully run "stat /tmp/testrpms/TestA-2-1.noarch.rpm"
        # check that downloaded .rpm is the same as the one in the repo
        And I successfully run "bash -c 'diff /tmp/testrpms/TestA-2-1.noarch.rpm /var/www/html/tmp*/TestA-2-1.noarch.rpm'"

  Scenario: dnf download --source --destdir --verbose (when there is such pkg)
       When I successfully run "bash -c 'rm -f /tmp/testrpms/TestA*'"
        And I successfully run "dnf download --source --verbose --destdir /tmp/testrpms TestA"
       Then the command stdout should match regexp "TestA-2.*src.rpm" 
        # check that the file has been downloaded into working directory
        And I successfully run "stat /tmp/testrpms/TestA-2-1.src.rpm"
        # check that downloaded .rpm is the same as the one in the repo
        And I successfully run "bash -c 'diff /tmp/testrpms/TestA-2-1.src.rpm /var/www/html/tmp*-source/TestA-2-1.src.rpm'"

  Scenario: dnf download --resolve (download dependencies when some are installed)
       When I successfully run "bash -c 'rm -f Test*rpm'"
        And I successfully run "dnf -y install TestE"
        And I successfully run "dnf download --resolve TestA"
       Then the command stdout should match regexp "TestA-2.*rpm"
        And the command stdout should match regexp "TestC-1.*rpm" 
        And the command stdout should not match regexp "TestE-1.*rpm" 
        And I successfully run "stat TestA-2-1.noarch.rpm"
        And I successfully run "bash -c 'diff TestA-2-1.noarch.rpm /var/www/html/tmp*/TestA-2-1.noarch.rpm'"
        And I successfully run "stat TestC-1-1.noarch.rpm"
        And I successfully run "bash -c 'diff TestC-1-1.noarch.rpm /var/www/html/tmp*/TestC-1-1.noarch.rpm'"
       When I run "stat TestE-1-1.noarch.rpm"
       Then the command should fail
        # cleanup of downloaded files
        And I successfully run "bash -c 'rm -f Test*rpm'"

  Scenario: dnf download --resolve --destdir (download dependencies when all are installed)
       When I successfully run "bash -c 'rm -f /tmp/testrpms/Test*rpm'"
        And I successfully run "dnf -y install TestA"
        And I successfully run "dnf download --resolve --destdir /tmp/testrpms TestA"
       # only TestA should be downloaded (no matter that it is installed)
       Then the command stdout should match regexp "TestA-2.*rpm"
        And the command stdout should not match regexp "TestC-1.*rpm" 
        And the command stdout should not match regexp "TestE-1.*rpm" 
        And I successfully run "stat /tmp/testrpms/TestA-2-1.noarch.rpm"
        And I successfully run "bash -c 'diff /tmp/testrpms/TestA-2-1.noarch.rpm /var/www/html/tmp*/TestA-2-1.noarch.rpm'"
       When I run "stat /tmp/testrpms/TestC-1-1.noarch.rpm"
       Then the command should fail
       When I run "stat /tmp/testrpms/TestE-1-1.noarch.rpm"
       Then the command should fail
        # cleanup of downloaded files and the test dir
        And I successfully run "bash -c 'rm -rf /tmp/testrpms'"
