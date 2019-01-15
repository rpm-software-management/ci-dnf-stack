Feature: repo-packages remove


  Scenario: Remove packages from available repository, also remove their 
    dependencies and packages that depend on them (even from other repositories)
Given I use the repository "dnf-ci-fedora"
Given I use the repository "dnf-ci-fedora-updates"
 When I execute dnf with args "install CQRlib-devel libzstd"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                                   |
      | install       | glibc-0:2.28-26.fc29.x86_64               |
      | install       | glibc-common-0:2.28-26.fc29.x86_64        |
      | install       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
      | install       | basesystem-0:11-6.fc29.noarch             |
      | install       | filesystem-0:3.9-2.fc29.x86_64            |
      | install       | setup-0:2.12.1-1.fc29.noarch              |
      | install       | CQRlib-0:1.1.2-16.fc29.x86_64             |
      | install       | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |
      | install       | libzstd-0:1.3.6-1.fc29.x86_64             |
 When I execute dnf with args "repo-packages dnf-ci-fedora remove"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                                   |
      | remove        | glibc-0:2.28-26.fc29.x86_64               |
      | remove        | glibc-common-0:2.28-26.fc29.x86_64        |
      | remove        | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
      | remove        | basesystem-0:11-6.fc29.noarch             |
      | remove        | filesystem-0:3.9-2.fc29.x86_64            |
      | remove        | setup-0:2.12.1-1.fc29.noarch              |
      | remove        | CQRlib-0:1.1.2-16.fc29.x86_64             |
      | remove        | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |
      | remove        | libzstd-0:1.3.6-1.fc29.x86_64             |
