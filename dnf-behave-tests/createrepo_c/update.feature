Feature: Tests createrepo_c --update


Background: Prepare repository folder
Given I create directory "/temp-repo/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-libs-0.2.1-1.fc29.x86_64.rpm" to "/temp-repo"
  And I create symlink "/temp-repo/package-devel-0.2.1-1.fc29.x86_64.rpm" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-devel-0.2.1-1.fc29.x86_64.rpm"
  And I create symlink "/temp-repo/package-0.2.1-1.fc29.src.rpm" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages/src/package-0.2.1-1.fc29.src.rpm"


Scenario: --update on empty repo
Given I create directory "/empty-repo/"
  And I execute createrepo_c with args "." in "/empty-repo"
 When I execute createrepo_c with args "--update ." in "/empty-repo"
 Then the exit code is 0
  And repodata "/empty-repo/repodata/" are consistent
  And repodata in "/empty-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |


Scenario: --update on empty repo with simplified filenames
Given I create directory "/empty-repo/"
  And I execute createrepo_c with args "." in "/empty-repo"
 When I execute createrepo_c with args "--simple-md-filenames --update ." in "/empty-repo"
 Then the exit code is 0
  And repodata "/empty-repo/repodata/" are consistent
  And repodata in "/empty-repo/repodata/" is
      | Type         | File                 | Checksum Type | Compression Type |
      | primary      | primary.xml.gz       | sha256        | gz               |
      | filelists    | filelists.xml.gz     | sha256        | gz               |
      | other        | other.xml.gz         | sha256        | gz               |


Scenario: --update discards additional metadata
Given I create directory "/empty-repo/"
  And I create file "/groupfile.xml" with
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE comps PUBLIC "-//Red Hat, Inc.//DTD Comps info//EN" "comps.dtd">
      <comps>
      </comps>
      """
  And I execute createrepo_c with args "--groupfile ../groupfile.xml ." in "/empty-repo"
  And repodata "/empty-repo/repodata/" are consistent
  And repodata in "/empty-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |
      | group        | ${checksum}-groupfile.xml        | sha256        | -                |
      | group_gz     | ${checksum}-groupfile.xml.gz     | sha256        | gz               |
 When I execute createrepo_c with args "--update ." in "/empty-repo"
 Then the exit code is 0
  And repodata "/empty-repo/repodata/" are consistent
  And repodata in "/empty-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |


Scenario: --update on repo with packages
Given I execute createrepo_c with args "." in "/temp-repo"
  And repodata "/temp-repo/repodata/" are consistent
 When I execute createrepo_c with args "--update ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |


Scenario: --update twice on repo with packages
Given I execute createrepo_c with args "." in "/temp-repo"
  And repodata "/temp-repo/repodata/" are consistent
 When I execute createrepo_c with args "--update ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
 When I execute createrepo_c with args "--update ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |


Scenario: --update with --update-md-path
Given I create directory "/updated-repo/"
  And I execute createrepo_c with args "." in "/temp-repo"
 When I execute createrepo_c with args "--update --update-md-path {context.scenario.default_tmp_dir}/temp-repo ." in "/updated-repo"
 Then the exit code is 0
  And repodata "/updated-repo/repodata/" are consistent
  And repodata in "/updated-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |


Scenario: --update with --update-md-path twice
Given I create directory "/updated-repo/"
  And I execute createrepo_c with args "." in "/temp-repo"
 When I execute createrepo_c with args "--update --update-md-path {context.scenario.default_tmp_dir}/temp-repo ." in "/updated-repo"
 Then the exit code is 0
  And repodata "/updated-repo/repodata/" are consistent
 When I execute createrepo_c with args "--update --update-md-path {context.scenario.default_tmp_dir}/temp-repo ." in "/updated-repo"
 Then the exit code is 0
  And repodata "/updated-repo/repodata/" are consistent
  And repodata in "/updated-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |


Scenario: --update with no changes doesn't update the files
Given I execute createrepo_c with args "." in "/temp-repo"
  And repodata "/temp-repo/repodata/" are consistent
 When I execute createrepo_c with args "--update ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And stdout is
  """
  Directory walk started
  Directory walk done - 4 packages
  Loaded information about 4 packages
  Temporary output repo path: ./.repodata/
  Pool started (with 5 workers)
  Pool finished
  New and old repodata match, not updating.
  """


Scenario: --update with added distro tags updates repo
Given I execute createrepo_c with args "." in "/temp-repo"
  And repodata "/temp-repo/repodata/" are consistent
 When I execute createrepo_c with args "--update --distro '12312,name' ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And stdout is
  """
  Directory walk started
  Directory walk done - 4 packages
  Loaded information about 4 packages
  Temporary output repo path: ./.repodata/
  Pool started (with 5 workers)
  Pool finished
  """
