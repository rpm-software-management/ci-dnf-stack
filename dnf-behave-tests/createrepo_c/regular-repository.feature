Feature: Tests createrepo_c on regular repository with packages


Background: Prepare repository folder
Given I create directory "/temp-repo/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo"
  And I create symlink "/temp-repo/package-devel-0.2.1-1.fc29.x86_64.rpm" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-devel-0.2.1-1.fc29.x86_64.rpm"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo"


Scenario: create regular consistent repository with specified packaged and relative path
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
      | package-devel | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs  | 0     | 0.2.1   | 1.fc29  | x86_64       |


Scenario: create regular consistent repository with specified packaged and absolute path
 When I execute createrepo_c with args "{context.scenario.default_tmp_dir}/temp-repo" in "/"
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
      | package-devel | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs  | 0     | 0.2.1   | 1.fc29  | x86_64       |


Scenario: create regular consistent repository while excluding all packages
 When I execute createrepo_c with args ". --excludes '*'" in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                                | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.gz          | sha256        | gz               |
      | filelists           | ${checksum}-filelists.xml.gz        | sha256        | gz               |
      | other               | ${checksum}-other.xml.gz            | sha256        | gz               |
  And primary in "/temp-repo/repodata" doesn't have any packages


Scenario: create regular consistent repository while excluding specific packages
 When I execute createrepo_c with args ". --excludes 'package-devel-0.2.1-1.fc29.x86_64.rpm'" in "/temp-repo"
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


Scenario: create regular consistent repository while excluding packages by wildcards
 When I execute createrepo_c with args ". --excludes '*devel-*.rpm'" in "/temp-repo"
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


Scenario: create regular consistent repository wihile skipping symlinks
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


Scenario: create regular consistent repository with package list
Given I create file "/temp-repo/pkglist.txt" with
      """
      package-0.2.1-1.fc29.x86_64.rpm
      package-libs-0.2.1-1.fc29.x86_64.rpm
      """
 When I execute createrepo_c with args "--pkglist pkglist.txt ." in "/temp-repo"
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


Scenario: create regular consistent repository with package list and absolute path
Given I create file "/temp-repo/pkglist.txt" with
      """
      package-0.2.1-1.fc29.x86_64.rpm
      package-libs-0.2.1-1.fc29.x86_64.rpm
      """
 When I execute createrepo_c with args "--pkglist {context.scenario.default_tmp_dir}/temp-repo/pkglist.txt {context.scenario.default_tmp_dir}/temp-repo" in "/"
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


Scenario: create regular consistent repository with package list with empty lines
Given I create file "/temp-repo/pkglist.txt" with
      """

      package-0.2.1-1.fc29.x86_64.rpm


      package-libs-0.2.1-1.fc29.x86_64.rpm

      """
 When I execute createrepo_c with args "--pkglist pkglist.txt ." in "/temp-repo"
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
