Feature: Tests mergerepo_c --archlist and --arch-expand options

Background: Prepare two repositories with various architectures
Given I create directory "/repo1/"
  And I create directory "/repo2/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/i386/arch-package-a-0.0.1-1.fc29.i386.rpm" to "/repo1"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/i686/arch-package-b-0.0.1-1.fc29.i686.rpm" to "/repo1"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/ppc64/arch-package-c-0.0.1-1.fc29.ppc64.rpm" to "/repo2"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/repo2"
  And I execute createrepo_c with args "." in "/repo1"
  And I execute createrepo_c with args "." in "/repo2"


Scenario: merged repository contains packages of all arches by default
 When I execute mergerepo_c with args "--repo {context.scenario.default_tmp_dir}/repo1 --repo {context.scenario.default_tmp_dir}/repo2" in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/merged_repo/repodata/" are consistent
  And primary in "/merged_repo/repodata" has only packages
      | Name           | Epoch | Version | Release | Architecture |
      | arch-package-a | 0     | 0.0.1   | 1.fc29  | i386         |
      | arch-package-b | 0     | 0.0.1   | 1.fc29  | i686         |
      | arch-package-c | 0     | 0.0.1   | 1.fc29  | ppc64        |
      | package        | 0     | 0.2.1   | 1.fc29  | x86_64       |


Scenario: --arch-expand cannot be used without --archlist
 When I execute mergerepo_c with args "--repo {context.scenario.default_tmp_dir}/repo1 --repo {context.scenario.default_tmp_dir}/repo2 --arch-expand" in "/"
 Then the exit code is 1
  And stderr is
      """
      Critical: --arch-expand cannot be used without -a/--archlist argument
      """


Scenario: merged repository contains packages only for architecture specified by archlist
 When I execute mergerepo_c with args "--repo {context.scenario.default_tmp_dir}/repo1 --repo {context.scenario.default_tmp_dir}/repo2 --archlist i386" in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/merged_repo/repodata/" are consistent
  And primary in "/merged_repo/repodata" has only packages
      | Name           | Epoch | Version | Release | Architecture |
      | arch-package-a | 0     | 0.0.1   | 1.fc29  | i386         |


Scenario: using --arch-expand merged repository contains packages for x86_64, arches expanded from it and arches expanded from its multilib arches
 When I execute mergerepo_c with args "--repo {context.scenario.default_tmp_dir}/repo1 --repo {context.scenario.default_tmp_dir}/repo2 --archlist x86_64 --arch-expand" in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/merged_repo/repodata/" are consistent
  And primary in "/merged_repo/repodata" has only packages
      | Name           | Epoch | Version | Release | Architecture |
      | arch-package-a | 0     | 0.0.1   | 1.fc29  | i386         |
      | arch-package-b | 0     | 0.0.1   | 1.fc29  | i686         |
      | package        | 0     | 0.2.1   | 1.fc29  | x86_64       |


Scenario: using --arch-expand merged repository contains packages only for i386 and arches expanded from it, no other since its not multilib arch
 When I execute mergerepo_c with args "--repo {context.scenario.default_tmp_dir}/repo1 --repo {context.scenario.default_tmp_dir}/repo2 --archlist i386 --arch-expand" in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/merged_repo/repodata/" are consistent
  And primary in "/merged_repo/repodata" has only packages
      | Name           | Epoch | Version | Release | Architecture |
      | arch-package-a | 0     | 0.0.1   | 1.fc29  | i386         |
      | arch-package-b | 0     | 0.0.1   | 1.fc29  | i686         |


Scenario: using --arch-expand merged repository contains packages only for architecture i686 specified by archlist because its not multilib and doesn't expand
 When I execute mergerepo_c with args "--repo {context.scenario.default_tmp_dir}/repo1 --repo {context.scenario.default_tmp_dir}/repo2 --archlist i686 --arch-expand" in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/merged_repo/repodata/" are consistent
  And primary in "/merged_repo/repodata" has only packages
      | Name           | Epoch | Version | Release | Architecture |
      | arch-package-b | 0     | 0.0.1   | 1.fc29  | i686         |
