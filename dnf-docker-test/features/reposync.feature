Feature: Reposync

  @setup
  Scenario: Feature Setup
      Given http repository "base" with packages
         | Package  | Tag       | Value  |
         | TestA    | Version   |  1     |
         | TestA v2 | Requires  | TestB  |
         |          | Version   |  2     |
         | TestB    | Version   |  1     |
        And package groups defined in repository "base"
         | Group     | Tag         | Value   |
         | TestGroup | mandatory   | TestB   |
       When I enable repository "base"

  Scenario: Reposync --newest-only
     When I successfully run "dnf reposync --download-path=. --repoid base --newest-only"
        # TestA-2 is downloaded
     When I successfully run "stat base/TestA-2-1.noarch.rpm"
        # TestA-1 is not downloaded
      And I run "stat base/TestA-1-1.noarch.rpm"
     Then the command should fail
        # downloaded RPM is the same as in repo
      And I successfully run "bash -c 'diff  base/TestA-2-1.noarch.rpm /var/www/html/tmp*/TestA-2-1.noarch.rpm'"

  Scenario: Reposync
     When I successfully run "dnf reposync --download-path=. --repoid base"
        # TestA-1 is downloaded
     Then I successfully run "stat base/TestA-1-1.noarch.rpm"
        # downloaded RPM is the same as in repo
      And I successfully run "bash -c 'diff  base/TestA-1-1.noarch.rpm /var/www/html/tmp*/TestA-1-1.noarch.rpm'"

  # https://bugzilla.redhat.com/show_bug.cgi?id=1653126
  @bz1653126
  Scenario: Reposync --downloadcomps
     When I successfully run "dnf reposync --download-path=. --repoid base --downloadcomps"
        # comps file is downloaded
     Then I successfully run "stat base/comps.xml"
        # downloaded comps file is the same as in repo
      And I successfully run "bash -c 'diff  base/comps.xml /var/www/html/tmp*/comps.xml'"

  Scenario: Reposync --download-metadata
     When I successfully run "dnf reposync --download-path=. --repoid base --download-metadata"
        # repodata are downloaded
     Then I successfully run "stat base/repodata/"
        # downloaded repodata are the same as in repo
      And I successfully run "bash -c 'diff -r base/repodata/ $(find /var/www/html/ -maxdepth 1 -name tmp\* -and -not -name tmp\*-source)/repodata'"
