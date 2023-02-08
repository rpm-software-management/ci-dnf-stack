Feature: Tests createrepo_c with duplicate (same NEVRA) packages present


Background:
Given I create directory "/temp-repo/"
  And I create directory "/temp-repo/subdir"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo"


Scenario: report all duplicate packages
Given I create directory "/temp-repo/subdir22"
  And I create directory "/temp-repo/subdir333"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo/subdir"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo/subdir22"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo/subdir333"
 When I execute createrepo_c with args "." in "/temp-repo"
 Then the exit code is 0
  And stdout is
      """
      Directory walk started
      Directory walk done - 4 packages
      Temporary output repo path: ./.repodata/
      Pool started (with 5 workers)
      Pool finished
      """
  And stderr matches line by line
  """
  Warning: Package 'package-0:0.2.1-1.fc29.x86_64' has duplicate metadata entries, only one should exist
  Warning:     Sourced from location: 'package-0.2.1-1.fc29.x86_64.rpm', build timestamp: .*
  Warning:     Sourced from location: 'subdir/package-0.2.1-1.fc29.x86_64.rpm', build timestamp: .*
  Warning:     Sourced from location: 'subdir22/package-0.2.1-1.fc29.x86_64.rpm', build timestamp: .*
  Warning:     Sourced from location: 'subdir333/package-0.2.1-1.fc29.x86_64.rpm', build timestamp: .*
  """
  And repodata "/temp-repo/repodata/" are consistent


Scenario: --update with two packages with the same NEVRA but different checksums reports duplicates
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages-2/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo/subdir/package-0.2.1-1.fc29.x86_64.rpm"
 When I execute createrepo_c with args "." in "/temp-repo"
 Then the exit code is 0
  And stderr matches line by line
  """
  Warning: Package 'package-0:0.2.1-1.fc29.x86_64' has duplicate metadata entries, only one should exist
  Warning:     Sourced from location: 'package-0.2.1-1.fc29.x86_64.rpm', build timestamp: .*
  Warning:     Sourced from location: 'subdir/package-0.2.1-1.fc29.x86_64.rpm', build timestamp: .*
  """
 When I execute createrepo_c with args "--update ." in "/temp-repo"
 Then the exit code is 0
  And stdout is
      """
      Directory walk started
      Directory walk done - 2 packages
      Loaded information about 2 packages
      Temporary output repo path: ./.repodata/
      Pool started (with 5 workers)
      Pool finished
      New and old repodata match, not updating.
      """
  And repodata "/temp-repo/repodata/" are consistent
  And stderr matches line by line
  """
  Warning: Package 'package-0:0.2.1-1.fc29.x86_64' has duplicate metadata entries, only one should exist
  Warning:     Sourced from location: 'package-0.2.1-1.fc29.x86_64.rpm', build timestamp: .*
  Warning:     Sourced from location: 'subdir/package-0.2.1-1.fc29.x86_64.rpm', build timestamp: .*
  """


Scenario: --update with two packages with the same NEVRA and checksums reports duplicates
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo/subdir/package-0.2.1-1.fc29.x86_64.rpm"
 When I execute createrepo_c with args "." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
 When I execute createrepo_c with args "--update ." in "/temp-repo"
 Then the exit code is 0
  And stdout is
      """
      Directory walk started
      Directory walk done - 2 packages
      Loaded information about 1 packages
      Temporary output repo path: ./.repodata/
      Pool started (with 5 workers)
      Pool finished
      New and old repodata match, not updating.
      """
  And repodata "/temp-repo/repodata/" are consistent
