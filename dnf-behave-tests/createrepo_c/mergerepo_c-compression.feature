Feature: Tests for mergerepo_c compression options


Background: Prepare two repositories
Given I create directory "/repo1/"
  And I create directory "/repo2/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/repo1"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-devel-0.2.1-1.fc29.x86_64.rpm" to "/repo2"
  And I execute createrepo_c with args "." in "/repo1"
  And I execute createrepo_c with args "." in "/repo2"


Scenario: Merged repository has xz compression
 When I execute mergerepo_c with args "--compress-type xz --repo {context.scenario.default_tmp_dir}/repo1 --repo {context.scenario.default_tmp_dir}/repo2" in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/merged_repo/repodata/" are consistent
  And repodata in "/merged_repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.xz       | sha256        | xz               |
      | filelists    | ${checksum}-filelists.xml.xz     | sha256        | xz               |
      | other        | ${checksum}-other.xml.xz         | sha256        | xz               |
      | updateinfo   | ${checksum}-updateinfo.xml.xz    | sha256        | xz               |


Scenario: Merged repository has zstd compression
 When I execute mergerepo_c with args "--compress-type zstd --repo {context.scenario.default_tmp_dir}/repo1 --repo {context.scenario.default_tmp_dir}/repo2" in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/merged_repo/repodata/" are consistent
  And repodata in "/merged_repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |
      | updateinfo   | ${checksum}-updateinfo.xml.zst   | sha256        | zstd             |
