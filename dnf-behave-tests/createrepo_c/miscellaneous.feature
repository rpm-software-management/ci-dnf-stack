Feature: Tests createrepo_c basic functionality


Scenario: prints help
 When I execute createrepo_c with args "--help" in "."
 Then the exit code is 0
  And stderr is empty


Scenario: stderr is empty on successful run
 When I execute createrepo_c with args "." in "/"
 Then the exit code is 0
  And stderr is empty


Scenario: can create bit identical builds using --set-timestamp-to-revison
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I create directory "/repo1/"
  And I create directory "/repo2/"
 When I execute createrepo_c with args "--revision 1 --set-timestamp-to-revision -o repo1 ." in "/"
  And I execute createrepo_c with args "--revision 1 --set-timestamp-to-revision -o repo2 ." in "/"
 Then the files "{context.scenario.default_tmp_dir}/repo1" and "{context.scenario.default_tmp_dir}/repo2" do not differ
