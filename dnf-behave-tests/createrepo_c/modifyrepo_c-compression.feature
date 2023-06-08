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
 When I execute modifyrepo_c with args "--compress-type gz ../modules.yaml.xz ./repodata" in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                             | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists           | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other               | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | modules             | ${checksum}-modules.yaml.gz      | sha256        | gz               |

