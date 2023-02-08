Feature: Tests createrepo_c on repository with sub directories


Background: Prepare repository folder
Given I create directory "/temp-repo/"
  And I create directory "/temp-repo/a"
  And I create directory "/temp-repo/a/b"
  And I create directory "/temp-repo/c"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo"
  And I create symlink "/temp-repo/a/package-devel-0.2.1-1.fc29.x86_64.rpm" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-devel-0.2.1-1.fc29.x86_64.rpm"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo/a/b"
  And I create symlink "/temp-repo/c/package-0.2.1-1.fc29.src.rpm" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages/src/package-0.2.1-1.fc29.src.rpm"


Scenario: repository with packages in subdirs
 When I execute createrepo_c with args "." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                                | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.gz          | sha256        | gz               |
      | filelists           | ${checksum}-filelists.xml.gz        | sha256        | gz               |
      | other               | ${checksum}-other.xml.gz            | sha256        | gz               |
  And primary in "/temp-repo/repodata" has only packages
      | Name          | Epoch | Version | Release | Architecture |
      | package       | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package       | 0     | 0.2.1   | 1.fc29  | src          |
      | package-devel | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs  | 0     | 0.2.1   | 1.fc29  | x86_64       |


Scenario: repository with packages in subdirs while skipping symlinks
 When I execute createrepo_c with args "--skip-symlinks ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                                | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.gz          | sha256        | gz               |
      | filelists           | ${checksum}-filelists.xml.gz        | sha256        | gz               |
      | other               | ${checksum}-other.xml.gz            | sha256        | gz               |
  And primary in "/temp-repo/repodata" has only packages
      | Name          | Epoch | Version | Release | Architecture |
      | package       | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs  | 0     | 0.2.1   | 1.fc29  | x86_64       |


Scenario: repository with packages in subdirs while excluding packages
 When I execute createrepo_c with args "--excludes '*devel-*' ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                                | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.gz          | sha256        | gz               |
      | filelists           | ${checksum}-filelists.xml.gz        | sha256        | gz               |
      | other               | ${checksum}-other.xml.gz            | sha256        | gz               |
  And primary in "/temp-repo/repodata" has only packages
      | Name          | Epoch | Version | Release | Architecture |
      | package       | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package       | 0     | 0.2.1   | 1.fc29  | src          |
      | package-libs  | 0     | 0.2.1   | 1.fc29  | x86_64       |


@bz1348215
Scenario: repository with packages in subdirs with rpm in name
Given I create directory "/temp-repo/d.rpm"
  And I create directory "/temp-repo/d.rpm/e"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/python2-package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo/d.rpm/"
  And I create symlink "/temp-repo/d.rpm/e//python3-package-0.2.1-1.fc29.x86_64.rpm" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/python3-package-0.2.1-1.fc29.x86_64.rpm"
 When I execute createrepo_c with args "." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                                | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.gz          | sha256        | gz               |
      | filelists           | ${checksum}-filelists.xml.gz        | sha256        | gz               |
      | other               | ${checksum}-other.xml.gz            | sha256        | gz               |
  And primary in "/temp-repo/repodata" has only packages
      | Name            | Epoch | Version | Release | Architecture |
      | package         | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | python2-package | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | python3-package | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package         | 0     | 0.2.1   | 1.fc29  | src          |
      | package-devel   | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs    | 0     | 0.2.1   | 1.fc29  | x86_64       |
