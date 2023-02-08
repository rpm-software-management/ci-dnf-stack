Feature: Tests createrepo_c --update with --update-md-path


Background: Prepare side repository folder
Given I create directory "/main-repo/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/main-repo"


Scenario: --update-md-path doesn't work without --update
 When I execute createrepo_c with args "--update-md-path /i/lead/nowhere ." in "/main-repo"
 Then stderr matches line by line
      """

      \*\* \(createrepo_c:[0-9]*\): WARNING \*\*: .*: Usage of --update-md-path without --update has no effect!
      """
  And the exit code is 0
  And stdout matches line by line
      """
      Directory walk started
      Directory walk done - 1 packages
      Temporary output repo path: ./.repodata/
      Pool started \(with 5 workers\)
      Pool finished
      """
  And repodata "/main-repo/repodata/" are consistent


@bz1762697
Scenario: Invalid path passed to --update-md-path doesn't cause a crash
 When I execute createrepo_c with args "--update --update-md-path /i/lead/nowhere ." in "/main-repo"
 Then stderr is
      """
      C_CREATEREPOLIB: Warning: cr_get_local_metadata: /i/lead/nowhere is not a directory
      Warning: Metadata from md-path /i/lead/nowhere - loading failed: Metadata not found at /i/lead/nowhere.
      """
  And the exit code is 0
  And stdout matches line by line
      """
      Directory walk started
      Directory walk done - 1 packages
      Loading metadata from md-path: /i/lead/nowhere
      Loaded information about 0 packages
      Temporary output repo path: ./.repodata/
      Pool started \(with 5 workers\)
      Pool finished
      """
  And repodata "/main-repo/repodata/" are consistent


Scenario: Two packages are loaded and reused using --update-md-path and old metadata from outputdir
Given I create directory "/side-repo/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/side-repo"
  And I execute createrepo_c with args "." in "/side-repo"
  And I execute createrepo_c with args "." in "/main-repo"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/main-repo"
 When I execute createrepo_c with args "--update --update-md-path /{context.scenario.default_tmp_dir}/side-repo ." in "/main-repo"
 Then the exit code is 0
  And stdout matches line by line
      """
      Directory walk started
      Directory walk done - 2 packages
      Loading metadata from md-path: //tmp/createrepo_c_ci_tempdir_.*/side-repo
      Loaded information about 2 packages
      Temporary output repo path: ./.repodata/
      Pool started \(with 5 workers\)
      Pool finished
      """
  And repodata "/main-repo/repodata/" are consistent


Scenario: One package is loaded and reused using --update-md-path even if no old metadata are present in outputdir
Given I create directory "/side-repo/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/side-repo"
  And I execute createrepo_c with args "." in "/side-repo"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/main-repo"
 When I execute createrepo_c with args "--update --update-md-path /{context.scenario.default_tmp_dir}/side-repo ." in "/main-repo"
 Then the exit code is 0
  And stdout matches line by line
      """
      Directory walk started
      Directory walk done - 2 packages
      Loading metadata from md-path: //tmp/createrepo_c_ci_tempdir_.*/side-repo
      Loaded information about 1 packages
      Temporary output repo path: ./.repodata/
      Pool started \(with 5 workers\)
      Pool finished
      """
  And repodata "/main-repo/repodata/" are consistent


Scenario: Two packages are loaded and reused from multiple paths using --update-md-path
Given I create directory "/side-repo/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/side-repo"
  And I execute createrepo_c with args "." in "/side-repo"
  And I create directory "/side-repo-2/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-devel-0.2.1-1.fc29.x86_64.rpm" to "/side-repo-2"
  And I execute createrepo_c with args "." in "/side-repo-2"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/main-repo"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-devel-0.2.1-1.fc29.x86_64.rpm" to "/main-repo"
 When I execute createrepo_c with args "--update --update-md-path /{context.scenario.default_tmp_dir}/side-repo --update-md-path /{context.scenario.default_tmp_dir}/side-repo-2 ." in "/main-repo"
 Then the exit code is 0
  And stdout matches line by line
      """
      Directory walk started
      Directory walk done - 3 packages
      Loading metadata from md-path: //tmp/createrepo_c_ci_tempdir_.*/side-repo-2
      Loading metadata from md-path: //tmp/createrepo_c_ci_tempdir_.*/side-repo
      Loaded information about 2 packages
      Temporary output repo path: ./.repodata/
      Pool started \(with 5 workers\)
      Pool finished
      """
  And repodata "/main-repo/repodata/" are consistent
