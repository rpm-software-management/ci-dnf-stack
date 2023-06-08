Feature: Various tests sqliterepo_c


Background: Prepare repository folder
Given I create symlink "/createrepo_c-ci-packages" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages"


Scenario: Sqlitedbs already exist, sqliterepo_c without --foce should faild
Given I execute createrepo_c with args ". --database" in "/"
  And repodata "/repodata/" are consistent
 When I execute sqliterepo_c with args "." in "/"
 Then the exit code is 1
  And stderr is
      """
      Repository already has sqlitedb present in repomd.xml (You may use --force)
      """


Scenario: Sqlitedbs should be created
Given I execute createrepo_c with args "--no-database ." in "/"
 When I execute sqliterepo_c with args "." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |


Scenario: Sqlitedbs with simple file names should be created
Given I execute createrepo_c with args "--simple-md-filenames --no-database ." in "/"
 When I execute sqliterepo_c with args "." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                 | Checksum Type | Compression Type |
      | primary      | primary.xml.zst      | sha256        | zstd             |
      | filelists    | filelists.xml.zst    | sha256        | zstd             |
      | other        | other.xml.zst        | sha256        | zstd             |
      | primary_db   | primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | other.sqlite.bz2     | sha256        | bz2              |


Scenario: Sqlitedbs should be created using --force
Given I execute createrepo_c with args "--simple-md-filenames --database ." in "/"
 When I execute sqliterepo_c with args "--force ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                 | Checksum Type | Compression Type |
      | primary      | primary.xml.zst      | sha256        | zstd             |
      | filelists    | filelists.xml.zst    | sha256        | zstd             |
      | other        | other.xml.zst        | sha256        | zstd             |
      | primary_db   | primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | other.sqlite.bz2     | sha256        | bz2              |


Scenario: Sqlitedbs should be created using --force with different compresion --xz
Given I execute createrepo_c with args "." in "/"
 When I execute sqliterepo_c with args "--force --xz ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | primary_db   | ${checksum}-primary.sqlite.xz    | sha256        | xz               |
      | filelists_db | ${checksum}-filelists.sqlite.xz  | sha256        | xz               |
      | other_db     | ${checksum}-other.sqlite.xz      | sha256        | xz               |


Scenario: Sqlitedbs should be created using --force with different compresion --compress-type gz
Given I execute createrepo_c with args "." in "/"
 When I execute sqliterepo_c with args "--force --compress-type gz ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | primary_db   | ${checksum}-primary.sqlite.gz    | sha256        | gz               |
      | filelists_db | ${checksum}-filelists.sqlite.gz  | sha256        | gz               |
      | other_db     | ${checksum}-other.sqlite.gz      | sha256        | gz               |


Scenario: Sqlitedbs should be created using --force with different compresion --xz and old ones should be kept --keep-old
Given I execute createrepo_c with args ". --database" in "/"
 When I execute sqliterepo_c with args "--force --xz --keep-old ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | primary_db   | ${checksum}-primary.sqlite.xz    | sha256        | xz               |
      | filelists_db | ${checksum}-filelists.sqlite.xz  | sha256        | xz               |
      | other_db     | ${checksum}-other.sqlite.xz      | sha256        | xz               |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |


Scenario: Sqlitedbs should be created using --force and --local-sqlite
Given I execute createrepo_c with args "." in "/"
 When I execute sqliterepo_c with args "--force --local-sqlite ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |


Scenario: Sqlitedbs should be created using --force and --local-sqlite, --keep-old, --xz
Given I execute createrepo_c with args ". --database" in "/"
 When I execute sqliterepo_c with args "--force --local-sqlite --xz --keep-old ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |
      | primary_db   | ${checksum}-primary.sqlite.xz    | sha256        | xz               |
      | filelists_db | ${checksum}-filelists.sqlite.xz  | sha256        | xz               |
      | other_db     | ${checksum}-other.sqlite.xz      | sha256        | xz               |


Scenario: Sqlitedbs should be created using --force with different checksum
Given I execute createrepo_c with args "." in "/"
 When I execute sqliterepo_c with args "--force --checksum sha512 ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha512        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha512        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha512        | bz2              |


Scenario: Sqlitedbs should be created using zstd compression
Given I execute createrepo_c with args "--no-database ." in "/"
 When I execute sqliterepo_c with args "--compress-type zstd ." in "/"
 Then the exit code is 0
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists    | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other        | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | primary_db   | ${checksum}-primary.sqlite.zst   | sha256        | zstd             |
      | filelists_db | ${checksum}-filelists.sqlite.zst | sha256        | zstd             |
      | other_db     | ${checksum}-other.sqlite.zst     | sha256        | zstd             |
