Feature: Tests for modifyrepo_c command


@bz1776399
Scenario: Modifyrepo is able to work with metadata file which is a symlink
Given I create directory "/temp-repo/"
  And I create symlink "/temp-repo/createrepo_c-ci-packages" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages"
  And I create file "/modules-source.yaml" with
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
  And I execute createrepo_c with args "." in "/temp-repo"
  And I create symlink "modules.yaml" to file "modules-source.yaml"
 When I execute modifyrepo_c with args "../../modules.yaml ." in "/temp-repo/repodata"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                                | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.zst         | sha256        | zstd             |
      | filelists           | ${checksum}-filelists.xml.zst       | sha256        | zstd             |
      | other               | ${checksum}-other.xml.zst           | sha256        | zstd             |
      | modules             | ${checksum}-modules.yaml.zst        | sha256        | zstd             |


Scenario: Modifying repo with compressed metadata of the same compression type
Given I create directory "/temp-repo/"
  And I execute createrepo_c with args "." in "/temp-repo"
  And I create "gz" compressed file "/modules.yaml" with
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
 When I execute modifyrepo_c with args "../modules.yaml.gz ./repodata" in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                                | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.zst         | sha256        | zstd             |
      | filelists           | ${checksum}-filelists.xml.zst       | sha256        | zstd             |
      | other               | ${checksum}-other.xml.zst           | sha256        | zstd             |
      | modules             | ${checksum}-modules.yaml.zst        | sha256        | zstd             |


Scenario: Modifying repo with compressed metadata of different compression type
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
 When I execute modifyrepo_c with args "../modules.yaml.xz ./repodata" in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                                | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.zst         | sha256        | zstd             |
      | filelists           | ${checksum}-filelists.xml.zst       | sha256        | zstd             |
      | other               | ${checksum}-other.xml.zst           | sha256        | zstd             |
      | modules             | ${checksum}-modules.yaml.zst        | sha256        | zstd             |


# createrepo_c is compiled without support for zchunk on rhel 8 and 9
@not.with_os=rhel__ge__8
Scenario: Modifying repo with zck compressed metadata
Given I create directory "/temp-repo/"
  And I execute createrepo_c with args "--zck ." in "/temp-repo"
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
 When I execute modifyrepo_c with args "--compress-type zck ../modules.yaml.xz ./repodata" in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                             | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.zst      | sha256        | zstd             |
      | filelists           | ${checksum}-filelists.xml.zst    | sha256        | zstd             |
      | other               | ${checksum}-other.xml.zst        | sha256        | zstd             |
      | primary             | ${checksum}-primary.xml.zck      | sha256        | zck              |
      | filelists           | ${checksum}-filelists.xml.zck    | sha256        | zck              |
      | other               | ${checksum}-other.xml.zck        | sha256        | zck              |
      | modules             | ${checksum}-modules.yaml.zck     | sha256        | zck              |

