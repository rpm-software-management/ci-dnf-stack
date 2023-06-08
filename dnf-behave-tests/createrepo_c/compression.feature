Feature: Tests for createrepo_c compression options


Scenario: Empty repo with --general-compress-type zstd compression
 When I execute createrepo_c with args "--general-compress-type zstd ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                              | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst       | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst     | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst         | sha256        | zstd             |


Scenario: Repo with --general-compress-type zstd compression
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/"
 When I execute createrepo_c with args "--general-compress-type zstd ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                              | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst       | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst     | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst         | sha256        | zstd             |
  And primary in "/repodata/" has only packages
      | Name          | Epoch | Version | Release | Architecture |
      | package       | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs  | 0     | 0.2.1   | 1.fc29  | x86_64       |


Scenario: Empty repo with --compress-type zstd and --groupfile
Given I create file "/groupfile.xml" with
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE comps PUBLIC "-//Red Hat, Inc.//DTD Comps info//EN" "comps.dtd">
      <comps>
      </comps>
      """
 When I execute createrepo_c with args "--compress-type gz --groupfile groupfile.xml ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | group        | ${checksum}-groupfile.xml        | sha256        | -                |
      | group_zstd   | ${checksum}-groupfile.xml.gz     | sha256        | gz               |
  And primary in "/repodata/" doesn't have any packages


Scenario: --update on zstd repo with packages
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/"
  And I execute createrepo_c with args "." in "/"
 When I execute createrepo_c with args "--update --general-compress-type zstd ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                              | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst       | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst     | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst         | sha256        | zstd             |
  And primary in "/repodata/" has only packages
      | Name          | Epoch | Version | Release | Architecture |
      | package       | 0     | 0.2.1   | 1.fc29  | x86_64       |
      | package-libs  | 0     | 0.2.1   | 1.fc29  | x86_64       |
