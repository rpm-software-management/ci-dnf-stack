Feature: Tests createrepo_c with empty input repository


Background: Prepare empty folder
Given I create directory "/temp-repo/"
  And I create file "/groupfile.xml" with
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE comps PUBLIC "-//Red Hat, Inc.//DTD Comps info//EN" "comps.dtd">
      <comps>
      </comps>
      """


Scenario: Repo from empty directory with relative path
 When I execute createrepo_c with args "./temp-repo" in "/"
 Then the exit code is 0
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      # These exact file checksums may be fragile (different version of xml lib, slight change to format..)
      # | primary      | 1cb61ea996355add02b1426ed4c1780ea75ce0c04c5d1107c025c3fbd7d8bcae-primary.xml.zst      | sha256        | zstd             |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
  And repodata "/temp-repo/repodata/" are consistent


Scenario: Repo from empty directory with absolute path
 When I execute createrepo_c with args "{context.scenario.default_tmp_dir}/temp-repo" in "/"
 Then the exit code is 0
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
  And repodata "/temp-repo/repodata/" are consistent


Scenario: Repo with --database
 When I execute createrepo_c with args "--database ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |


Scenario: Repo with --no-database
 When I execute createrepo_c with args "--no-database ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |


Scenario: Repo with --groupfile
 When I execute createrepo_c with args "--groupfile ../groupfile.xml ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | group        | ${checksum}-groupfile.xml        | sha256        | -                |
      | group_gz     | ${checksum}-groupfile.xml.zst    | sha256        | zstd             |


Scenario: Repo with --groupfile and --checksum sha
 When I execute createrepo_c with args "--checksum sha224 --groupfile ../groupfile.xml ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha224        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha224        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha224        | zstd             |
      | group        | ${checksum}-groupfile.xml        | sha224        | -                |
      | group_gz     | ${checksum}-groupfile.xml.zst    | sha224        | zstd             |


Scenario: Repo with --simple-md-filenames and --groupfile
 When I execute createrepo_c with args "--simple-md-filenames --groupfile ../groupfile.xml ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                 | Checksum Type | Compression Type |
      | primary      | primary.xml.zst      | sha256        | zstd             |
      | filelists    | filelists.xml.zst    | sha256        | zstd             |
      | other        | other.xml.zst        | sha256        | zstd             |
      | group        | groupfile.xml        | sha256        | -                |
      | group_gz     | groupfile.xml.zst    | sha256        | zstd             |


Scenario: Repo with --unique-md-filenames and --groupfile
 When I execute createrepo_c with args "--unique-md-filenames --groupfile ../groupfile.xml ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | group        | ${checksum}-groupfile.xml        | sha256        | -                |
      | group_gz     | ${checksum}-groupfile.xml.zst    | sha256        | zstd             |


Scenario: Repo with --xz compression and --groupfile
 When I execute createrepo_c with args "--xz --groupfile ../groupfile.xml ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | group        | ${checksum}-groupfile.xml        | sha256        | -                |
      | group_xz     | ${checksum}-groupfile.xml.xz     | sha256        | xz               |


Scenario: Repo with --compress-type bz2 and --groupfile
 When I execute createrepo_c with args "--compress-type bz2 --groupfile ../groupfile.xml ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | group        | ${checksum}-groupfile.xml        | sha256        | -                |
      | group_bz2    | ${checksum}-groupfile.xml.bz2    | sha256        | bz2              |


Scenario: Repo with --compress-type gz
 When I execute createrepo_c with args "--compress-type gz --groupfile ../groupfile.xml ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | group        | ${checksum}-groupfile.xml        | sha256        | -                |
      | group_gz     | ${checksum}-groupfile.xml.gz     | sha256        | gz               |


Scenario: Repo with --compress-type xz
 When I execute createrepo_c with args "--compress-type xz --groupfile ../groupfile.xml ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | group        | ${checksum}-groupfile.xml        | sha256        | -                |
      | group_xz     | ${checksum}-groupfile.xml.xz     | sha256        | xz               |


Scenario: Repo with --repomd-checksum and --groupfile
 When I execute createrepo_c with args "--repomd-checksum sha224 --groupfile ../groupfile.xml ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha224        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha224        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha224        | zstd             |
      | group        | ${checksum}-groupfile.xml        | sha224        | -                |
      | group_gz     | ${checksum}-groupfile.xml.zst    | sha224        | zstd             |


Scenario: Repo with --checksum --repomd-checksum and --groupfile
 When I execute createrepo_c with args "--checksum sha256 --repomd-checksum sha512 --groupfile ../groupfile.xml ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha512        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha512        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha512        | zstd             |
      | group        | ${checksum}-groupfile.xml        | sha512        | -                |
      | group_gz     | ${checksum}-groupfile.xml.zst    | sha512        | zstd             |


Scenario: Repo with --general-compress-type and --groupfile
 When I execute createrepo_c with args "--general-compress-type xz --groupfile ../groupfile.xml ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.xz       | sha256        | xz               |
      | filelists    | ${checksum}-filelists.xml.xz     | sha256        | xz               |
      | other        | ${checksum}-other.xml.xz         | sha256        | xz               |
      | group        | ${checksum}-groupfile.xml        | sha256        | -                |
      | group_xz     | ${checksum}-groupfile.xml.xz     | sha256        | xz               |


Scenario: Repo without compression and --groupfile
 When I execute createrepo_c with args "--general-compress-type xz --groupfile ../groupfile.xml ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.xz       | sha256        | xz               |
      | filelists    | ${checksum}-filelists.xml.xz     | sha256        | xz               |
      | other        | ${checksum}-other.xml.xz         | sha256        | xz               |
      | group        | ${checksum}-groupfile.xml        | sha256        | -                |
      | group_xz     | ${checksum}-groupfile.xml.xz     | sha256        | xz               |


Scenario: Repo from empty directory with --distro DISTRO-TAG
 When I execute createrepo_c with args " --distro DISTRO-TAG ./temp-repo" in "/"
 Then the exit code is 0
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
  And repodata "/temp-repo/repodata/" are consistent
  And file "/temp-repo/repodata/repomd.xml" contains lines
      """
      <tags>
      \s+<distro>DISTRO-TAG</distro>
      </tags>
      """


Scenario: Repo from empty directory with --distro CPEID,Footag
 When I execute createrepo_c with args " --distro CPEID,Footag ./temp-repo" in "/"
 Then the exit code is 0
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
  And repodata "/temp-repo/repodata/" are consistent
  And file "/temp-repo/repodata/repomd.xml" contains lines
      """
      <tags>
      \s+<distro cpeid="CPEID">Footag</distro>
      </tags>
      """


Scenario: Repo from empty directory with multiple --distro CPEID,Footag
 When I execute createrepo_c with args " --distro cpeid,tag_a --distro tag_b ./temp-repo" in "/"
 Then the exit code is 0
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
  And repodata "/temp-repo/repodata/" are consistent
  And file "/temp-repo/repodata/repomd.xml" contains lines
      """
      <tags>
      \s+<distro cpeid="cpeid">tag_a</distro>
      \s+<distro>tag_b</distro>
      </tags>
      """


Scenario: Repo from empty directory with multiple --content contenttag
 When I execute createrepo_c with args "--content contenttag_b --content contenttag_a ./temp-repo" in "/"
 Then the exit code is 0
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
  And repodata "/temp-repo/repodata/" are consistent
  And file "/temp-repo/repodata/repomd.xml" contains lines
      """
      <tags>
      \s+<content>contenttag_a</content>
      \s+<content>contenttag_b</content>
      </tags>
      """


Scenario: Repo from empty directory with multiple --repo repotag
 When I execute createrepo_c with args "--repo repotag_a --repo repotag_b ./temp-repo" in "/"
 Then the exit code is 0
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
  And repodata "/temp-repo/repodata/" are consistent
  And file "/temp-repo/repodata/repomd.xml" contains lines
      """
      <tags>
      \s+<repo>repotag_a</repo>
      \s+<repo>repotag_b</repo>
      </tags>
      """


Scenario: Repo from empty directory with --revision XYZ
 When I execute createrepo_c with args "--revision XYZ ./temp-repo" in "/"
 Then the exit code is 0
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
  And repodata "/temp-repo/repodata/" are consistent
  And file "/temp-repo/repodata/repomd.xml" contains lines
      """
      <revision>XYZ</revision>
      """


Scenario: Repo from empty directory with --skip-symlinks and symlinked package
Given I create symlink "/temp-repo/package-0.2.1-1.fc29.x86_64.rpm" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/package-0.2.1-1.fc29.x86_64.rpm"
 When I execute createrepo_c with args "--skip-symlinks ." in "/temp-repo"
 Then the exit code is 0
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
  And repodata "/temp-repo/repodata/" are consistent
  And primary in "/temp-repo/repodata/" doesn't have any packages
