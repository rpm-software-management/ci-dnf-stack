Feature: Tests createrepo_c --update with duplicate (same NEVRA) packages present


Background:
Given I create directory "/temp-repo/"
  And I create directory "/temp-repo/subdir"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo"


Scenario: --update with two packages with the same NEVRA but different checksums and locations loads information about both
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-duplicate-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo/subdir/package-0.2.1-1.fc29.x86_64.rpm"
  And I execute createrepo_c with args "." in "/temp-repo"
 When I execute createrepo_c with args "--update ." in "/temp-repo"
 Then the exit code is 0
  And stdout is
      """
      Directory walk started
      Directory walk done - 2 packages
      Loaded information about 2 packages
      Temporary output repo path: ./.repodata/
      Preparing sqlite DBs
      Pool started (with 5 workers)
      Pool finished
      """
  And repodata "/temp-repo/repodata/" are consistent


Scenario: --update with two packages with the same NEVRA and checksums but different locations loads information just once
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo/subdir/package-0.2.1-1.fc29.x86_64.rpm"
  And I execute createrepo_c with args "." in "/temp-repo"
 When I execute createrepo_c with args "--update ." in "/temp-repo"
 Then the exit code is 0
  And stdout is
      """
      Directory walk started
      Directory walk done - 2 packages
      Loaded information about 1 packages
      Temporary output repo path: ./.repodata/
      Preparing sqlite DBs
      Pool started (with 5 workers)
      Pool finished
      """
  And repodata "/temp-repo/repodata/" are consistent
