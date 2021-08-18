Feature: Tests for modifyrepo_c compression options


Scenario: Modifying repo using --compress-type
Given I create directory "/temp-repo/"
  And I execute createrepo_c with args "." in "/temp-repo"
  And I create "xz" compressed file "/modules.yaml" with
      """
      ---
      document: modulemd
      version: 2
      data:
      name: ingredience
      stream: chicken
      version: 1
      arch: x86_64
      description: Made up module
      license:
      module:
      - MIT
      ...
      """
 When I execute modifyrepo_c with args "--compress-type zstd ../modules.yaml.xz ./repodata" in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                             | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists           | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other               | ${checksum}-other.xml.gz         | sha256        | gz               |
      | primary_db          | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db        | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db            | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |
      | modules             | ${checksum}-modules.yaml.zst     | sha256        | zstd             |

