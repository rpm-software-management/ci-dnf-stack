Feature: Tests createrepo_c --read-pkgs-list


Background: Prepare repository folder
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I create symlink "/package-devel-0.2.1-1.fc29.x86_64.rpm" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-devel-0.2.1-1.fc29.x86_64.rpm"


Scenario: --read-pkgs-list on empty repo
Given I create directory "empty-repo"
 When I execute createrepo_c with args "--read-pkgs-list list ." in "/empty-repo"
 Then the exit code is 0
  And repodata "/empty-repo/repodata/" are consistent
  And file "/empty-repo/list" contents is
      """
      """


Scenario: --read-pkgs-list on repo with packages
 When I execute createrepo_c with args "--read-pkgs-list list ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And file "/list" contains lines
      """
      package-libs-0.2.1-1.fc29.x86_64.rpm
      package-devel-0.2.1-1.fc29.x86_64.rpm
      package-0.2.1-1.fc29.x86_64.rpm
      """


Scenario: --read-pkgs-list lists all packages
Given I execute createrepo_c with args "." in "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/python2-package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/python3-package-0.2.1-1.fc29.x86_64.rpm" to "/"
 When I execute createrepo_c with args "--read-pkgs-list list ." in "/"
 Then the exit code is 0
  And file "/list" contains lines
      """
      python2-package-0.2.1-1.fc29.x86_64.rpm
      python3-package-0.2.1-1.fc29.x86_64.rpm
      package-libs-0.2.1-1.fc29.x86_64.rpm
      package-devel-0.2.1-1.fc29.x86_64.rpm
      package-0.2.1-1.fc29.x86_64.rpm
      """


# https://github.com/rpm-software-management/createrepo_c/issues/130
Scenario: --read-pkgs-list with --update doesn't list not updated packages
Given I execute createrepo_c with args "." in "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/python2-package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/python3-package-0.2.1-1.fc29.x86_64.rpm" to "/"
 When I execute createrepo_c with args "--read-pkgs-list list --update ." in "/"
 Then the exit code is 0
  And file "/list" contains lines
      """
      python2-package-0.2.1-1.fc29.x86_64.rpm
      python3-package-0.2.1-1.fc29.x86_64.rpm
      """


# https://github.com/rpm-software-management/createrepo_c/issues/130
Scenario: --read-pkgs-list with --update lists updated packages
Given I execute createrepo_c with args "." in "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages-2/x86_64/package-0.3.1-1.fc29.x86_64.rpm" to "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/python2-package-0.2.1-1.fc29.x86_64.rpm" to "/"
 When I execute createrepo_c with args "--read-pkgs-list list --update ." in "/"
 Then the exit code is 0
  And file "/list" contains lines
      """
      package-0.3.1-1.fc29.x86_64.rpm
      python2-package-0.2.1-1.fc29.x86_64.rpm
      """
