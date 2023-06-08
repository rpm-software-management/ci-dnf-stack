Feature: Tests createrepo_c --zck


# createrepo_c is compiled without support for zchunk on rhel 8
@not.with_os=rhel__ge__8
Scenario: create empty repository with zck metadata
 When I execute createrepo_c with args "--zck ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type                | File                             | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists           | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other               | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | primary_zck         | ${checksum}-primary.xml.zck      | sha256        | zck              |
      | filelists_zck       | ${checksum}-filelists.xml.zck    | sha256        | zck              |
      | other_zck           | ${checksum}-other.xml.zck        | sha256        | zck              |
  And primary in "/repodata/" doesn't have any packages


# createrepo_c is compiled without support for zchunk on rhel 8
@not.with_os=rhel__ge__8
Scenario: create repository with zck metadata
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/"
 When I execute createrepo_c with args "--zck ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type                | File                             | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists           | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other               | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | primary_zck         | ${checksum}-primary.xml.zck      | sha256        | zck              |
      | filelists_zck       | ${checksum}-filelists.xml.zck    | sha256        | zck              |
      | other_zck           | ${checksum}-other.xml.zck        | sha256        | zck              |
  And primary in "/repodata" has only packages
      | Name          | Epoch | Version | Release | Architecture |
      | package       | 0     | 0.2.1   | 1.fc29  | x86_64       |


# createrepo_c is compiled without support for zchunk on rhel 8
@not.with_os=rhel__ge__8
Scenario: create repository with zck metadata with bad package
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I create file "/afilethatlookslike.rpm" with
      """
      gibberish
      """
 When I execute createrepo_c with args "--zck ." in "/"
 Then the exit code is 2
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type                | File                             | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists           | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other               | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | primary_zck         | ${checksum}-primary.xml.zck      | sha256        | zck              |
      | filelists_zck       | ${checksum}-filelists.xml.zck    | sha256        | zck              |
      | other_zck           | ${checksum}-other.xml.zck        | sha256        | zck              |
  And primary in "/repodata" has only packages
      | Name          | Epoch | Version | Release | Architecture |
      | package       | 0     | 0.2.1   | 1.fc29  | x86_64       |


# createrepo_c is compiled without support for zchunk on rhel 8
@not.with_os=rhel__ge__8
Scenario: create repository with zck metadata usign dictionaries
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/"
Given I create directory "/dictionaries"
  And I create file "/dictionaries/primary.xml.zdict" with
      """
      primary foobar
      """
  And I create file "/dictionaries/filelists.xml.zdict" with
      """
      filelists foobar
      """
  And I create file "/dictionaries/other.xml.zdict" with
      """
      other foobar
      """
 When I execute createrepo_c with args "--zck --zck-dict-dir {context.scenario.default_tmp_dir}/dictionaries --simple-md-filenames ." in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type                | File                 | Checksum Type | Compression Type |
      | primary             | primary.xml.zst      | sha256        | zstd             |
      | filelists           | filelists.xml.zst    | sha256        | zstd             |
      | other               | other.xml.zst        | sha256        | zstd             |
      | primary_zck         | primary.xml.zck      | sha256        | zck              |
      | filelists_zck       | filelists.xml.zck    | sha256        | zck              |
      | other_zck           | other.xml.zck        | sha256        | zck              |
  And I execute "unzck --dict {context.scenario.default_tmp_dir}/repodata/primary.xml.zck" in "{context.scenario.default_tmp_dir}/"
  And I execute "unzck --dict {context.scenario.default_tmp_dir}/repodata/filelists.xml.zck" in "{context.scenario.default_tmp_dir}/"
  And I execute "unzck --dict {context.scenario.default_tmp_dir}/repodata/other.xml.zck" in "{context.scenario.default_tmp_dir}/"
  And file "/primary.xml.zdict" contents is
      """
      primary foobar
      """
  And file "/filelists.xml.zdict" contents is
      """
      filelists foobar
      """
  And file "/other.xml.zdict" contents is
      """
      other foobar
      """


# createrepo_c is compiled without support for zchunk on rhel 8
@not.with_os=rhel__ge__8
Scenario: create repository with zck and dictionary metadata with bad package
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I create file "/afilethatlookslike.rpm" with
      """
      gibberish
      """
Given I create directory "/dictionaries"
  And I create file "/dictionaries/primary.xml.zdict" with
      """
      primary foobar
      """
  And I create file "/dictionaries/filelists.xml.zdict" with
      """
      filelists foobar
      """
  And I create file "/dictionaries/other.xml.zdict" with
      """
      other foobar
      """
 When I execute createrepo_c with args "--zck --zck-dict-dir {context.scenario.default_tmp_dir}/dictionaries --simple-md-filenames ." in "/"
 Then the exit code is 2
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type                | File                 | Checksum Type | Compression Type |
      | primary             | primary.xml.zst      | sha256        | zstd             |
      | filelists           | filelists.xml.zst    | sha256        | zstd             |
      | other               | other.xml.zst        | sha256        | zstd             |
      | primary_zck         | primary.xml.zck      | sha256        | zck              |
      | filelists_zck       | filelists.xml.zck    | sha256        | zck              |
      | other_zck           | other.xml.zck        | sha256        | zck              |
  And I execute "unzck --dict {context.scenario.default_tmp_dir}/repodata/primary.xml.zck" in "{context.scenario.default_tmp_dir}/"
  And I execute "unzck --dict {context.scenario.default_tmp_dir}/repodata/filelists.xml.zck" in "{context.scenario.default_tmp_dir}/"
  And I execute "unzck --dict {context.scenario.default_tmp_dir}/repodata/other.xml.zck" in "{context.scenario.default_tmp_dir}/"
  And file "/primary.xml.zdict" contents is
      """
      primary foobar
      """
  And file "/filelists.xml.zdict" contents is
      """
      filelists foobar
      """
  And file "/other.xml.zdict" contents is
      """
      other foobar
      """
