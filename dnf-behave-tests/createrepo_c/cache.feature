Feature: Tests createrepo_c --cache option


Scenario: create and use cache files
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I create symlink "/package-devel-0.2.1-1.fc29.x86_64.rpm" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-devel-0.2.1-1.fc29.x86_64.rpm"
  And I create directory "/cache"
 When I execute createrepo_c with args "--cachedir ./cache ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type          | File                                | Checksum Type | Compression Type |
      | primary       | ${checksum}-primary.xml.gz          | sha256        | gz               |
      | filelists     | ${checksum}-filelists.xml.gz        | sha256        | gz               |
      | other         | ${checksum}-other.xml.gz            | sha256        | gz               |
      | primary_db    | ${checksum}-primary.sqlite.bz2      | sha256        | bz2              |
      | filelists_db  | ${checksum}-filelists.sqlite.bz2    | sha256        | bz2              |
      | other_db      | ${checksum}-other.sqlite.bz2        | sha256        | bz2              |
  And primary in "/repodata" has only packages
      | Name          | Epoch | Version | Release | Architecture |
      | package       | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs  | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-devel | 0     | 0.2.1   | 1.fc29  | x86_64       |
 When I execute createrepo_c with args "--cachedir ./cache ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type          | File                                | Checksum Type | Compression Type |
      | primary       | ${checksum}-primary.xml.gz          | sha256        | gz               |
      | filelists     | ${checksum}-filelists.xml.gz        | sha256        | gz               |
      | other         | ${checksum}-other.xml.gz            | sha256        | gz               |
      | primary_db    | ${checksum}-primary.sqlite.bz2      | sha256        | bz2              |
      | filelists_db  | ${checksum}-filelists.sqlite.bz2    | sha256        | bz2              |
      | other_db      | ${checksum}-other.sqlite.bz2        | sha256        | bz2              |
  And primary in "/repodata" has only packages
      | Name          | Epoch | Version | Release | Architecture |
      | package       | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs  | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-devel | 0     | 0.2.1   | 1.fc29  | x86_64       |
  And file "/cache/package-devel-0.2.1-1.fc29.x86_64.rpm-[a-z0-9]*-[a-z0-9]*-[a-z0-9]*" exists
  And file "/cache/package-libs-0.2.1-1.fc29.x86_64.rpm-[a-z0-9]*-[a-z0-9]*-[a-z0-9]*" exists
  And file "/cache/package-0.2.1-1.fc29.x86_64.rpm-[a-z0-9]*-[a-z0-9]*-[a-z0-9]*" exists
