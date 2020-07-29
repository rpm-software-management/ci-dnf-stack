Feature: Tests createrepo_c --update --recycle-pkglist


Background: Prepare repository folder
Given I create directory "/temp-repo-1/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo-1"
  And I execute createrepo_c with args "." in "/temp-repo-1"


Scenario: --update --recycle-pkglist does not include newly added package
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo-1"
 When I execute createrepo_c with args "--update --recycle-pkglist ." in "/temp-repo-1"
 Then the exit code is 0
  And repodata "/temp-repo-1/repodata/" are consistent
  And primary in "/temp-repo-1/repodata" has only packages
      | Name      | Epoch | Version | Release | Architecture |
      | package   | 0     | 0.2.1   | 1.fc29  | x86_64       |


Scenario: --update --recycle-pkglist respects --excludes
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo-1"
 When I execute createrepo_c with args "--update --recycle-pkglist --excludes package-0.2.1* ." in "/temp-repo-1"
 Then the exit code is 0
  And repodata "/temp-repo-1/repodata/" are consistent
  And primary in "/temp-repo-1/repodata" doesn't have any packages


Scenario: --update --recycle-pkglist adds packages from --pkglist
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo-1"
  And I create file "/list-of-packages" with
      """
      package-libs-0.2.1-1.fc29.x86_64.rpm
      """
 When I execute createrepo_c with args "--update --recycle-pkglist --pkglist /{context.scenario.default_tmp_dir}/list-of-packages ." in "/temp-repo-1"
 Then the exit code is 0
  And repodata "/temp-repo-1/repodata/" are consistent
  And primary in "/temp-repo-1/repodata" has only packages
      | Name         | Epoch | Version | Release | Architecture |
      | package      | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs | 0     | 0.2.1   | 1.fc29  | x86_64       |


Scenario: --update --recycle-pkglist adds packages from --includepkg
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/python2-package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-devel-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo-1"
 When I execute createrepo_c with args "--update --recycle-pkglist --includepkg ../package-libs-0.2.1-1.fc29.x86_64.rpm ." in "/temp-repo-1"
 Then the exit code is 0
  And stderr is empty
  And repodata "/temp-repo-1/repodata/" are consistent
  And primary in "/temp-repo-1/repodata" has only packages
      | Name         | Epoch | Version | Release | Architecture |
      | package      | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs | 0     | 0.2.1   | 1.fc29  | x86_64       |


Scenario: --update --recycle-pkglist respects --update-md-path
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo-1"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-devel-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo-1"
  And I create directory "/temp-repo-2/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-devel-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo-2"
  And I execute createrepo_c with args "." in "/temp-repo-2"
 When I execute createrepo_c with args "--update --recycle-pkglist --update-md-path /{context.scenario.default_tmp_dir}/temp-repo-2 ." in "/temp-repo-1"
 Then the exit code is 0
  And repodata "/temp-repo-1/repodata/" are consistent
  And primary in "/temp-repo-1/repodata" has only packages
      | Name          | Epoch | Version | Release | Architecture |
      | package       | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-devel | 0     | 0.2.1   | 1.fc29  | x86_64       |


@not.with_os=rhel__eq__8
Scenario: --update --recycle-pkglist does not include newly added package when running on existing empty repodata
Given I create directory "/temp-repo-empty/"
  And I execute createrepo_c with args "." in "/temp-repo-empty"
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo-empty"
 When I execute createrepo_c with args ". --update --recycle-pkglist" in "/temp-repo-empty"
 Then the exit code is 0
  And repodata "/temp-repo-empty/repodata/" are consistent
  And primary in "/temp-repo-empty/repodata" doesn't have any packages
