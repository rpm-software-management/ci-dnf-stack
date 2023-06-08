Feature: Tests mergerepo_c


Background: Prepare two repositories with various architectures
Given I create directory "/repo1/"
  And I create directory "/repo2/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/repo1"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/repo2"
  And I execute createrepo_c with args "." in "/repo1"
  And I execute createrepo_c with args "." in "/repo2"


Scenario: merged repository doesn't contain sqlite db by default
 When I execute mergerepo_c with args "--repo {context.scenario.default_tmp_dir}/repo1 --repo {context.scenario.default_tmp_dir}/repo2" in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/merged_repo/repodata/" are consistent
  And repodata in "/merged_repo/repodata/" is
      | Type         | File                          | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst   | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst     | sha256        | zstd             |
      | updateinfo   | ${checksum}-updateinfo.xml.zst| sha256        | zstd             |
  And primary in "/merged_repo/repodata" has only packages
      | Name         | Epoch | Version | Release | Architecture |
      | package      | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs | 0     | 0.2.1   | 1.fc29  | x86_64       |


Scenario: merged repository has sqlite db if specified
 When I execute mergerepo_c with args "--database --repo {context.scenario.default_tmp_dir}/repo1 --repo {context.scenario.default_tmp_dir}/repo2" in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/merged_repo/repodata/" are consistent
  And repodata in "/merged_repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | updateinfo   | ${checksum}-updateinfo.xml.zst   | sha256        | zstd             |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |
  And primary in "/merged_repo/repodata" has only packages
      | Name         | Epoch | Version | Release | Architecture |
      | package      | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs | 0     | 0.2.1   | 1.fc29  | x86_64       |
