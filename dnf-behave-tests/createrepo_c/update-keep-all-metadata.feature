Feature: Tests createrepo_c --update --kepp-all-metadata


Background: Prepare repository folder
Given I create directory "/temp-repo/"
  And I create symlink "/temp-repo/createrepo_c-ci-packages" to file "/{context.scenario.repos_location}/createrepo_c-ci-packages"
  And I create file "/groupfile2.xml" with
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE comps PUBLIC "-//Red Hat, Inc.//DTD Comps info//EN" "comps.dtd">
      <comps>
      </comps>
      """
  And I create file "/groupfile.xml" with
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE comps PUBLIC "-//Red Hat, Inc.//DTD Comps info//EN" "comps.dtd">
      <comps>
      </comps>
      """
  And I create file "/updateinfo.xml" with
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <updates>
      </updates>
      """
  And I create file "/modules.yaml" with
      """
      ---
      document: modulemd
      version: 2
      data:
        name: test-module
        stream: "modular-package1"
        version: 1
        arch: x86_64
        description: Made up module
        summary: Test module
        license:
          module:
          - MIT
        profiles:
          test-profile1:
            rpms:
            - modular-package1
        components:
          rpms:
            modular-package1: {rationale: 'rationale for modular-package1'}
        artifacts:
          rpms:
          - modular-package1-0:0.1-1.x86_64.rpm
      ...
      """
  And I create file "/custom_metadata.txt" with
      """
      Custom metadata
      """


Scenario: --update with --discard-additional-metadata discards additional metadata
Given I execute createrepo_c with args "--groupfile ../groupfile.xml ." in "/temp-repo"
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |
      | group        | ${checksum}-groupfile.xml        | sha256        | -                |
      | group_gz     | ${checksum}-groupfile.xml.gz     | sha256        | gz               |
 When I execute createrepo_c with args "--update --discard-additional-metadata ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |


Scenario: --update --keep-all-metadata keeps all additional metadata
Given I execute createrepo_c with args "--groupfile ../groupfile.xml ." in "/temp-repo"
  And I execute modifyrepo_c with args "../../updateinfo.xml ." in "/temp-repo/repodata"
  And I execute modifyrepo_c with args "../../custom_metadata.txt ." in "/temp-repo/repodata"
  And I execute modifyrepo_c with args "../../modules.yaml ." in "/temp-repo/repodata"
 When I execute createrepo_c with args "--update --keep-all-metadata ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type            | File                               | Checksum Type | Compression Type |
      | primary         | ${checksum}-primary.xml.gz         | sha256        | gz               |
      | filelists       | ${checksum}-filelists.xml.gz       | sha256        | gz               |
      | other           | ${checksum}-other.xml.gz           | sha256        | gz               |
      | primary_db      | ${checksum}-primary.sqlite.bz2     | sha256        | bz2              |
      | filelists_db    | ${checksum}-filelists.sqlite.bz2   | sha256        | bz2              |
      | other_db        | ${checksum}-other.sqlite.bz2       | sha256        | bz2              |
      | group           | ${checksum}-groupfile.xml          | sha256        | -                |
      | group_gz        | ${checksum}-groupfile.xml.gz       | sha256        | gz               |
      | updateinfo      | ${checksum}-updateinfo.xml.gz      | sha256        | gz               |
      | custom_metadata | ${checksum}-custom_metadata.txt.gz | sha256        | gz               |
      | modules         | ${checksum}-modules.yaml.gz        | sha256        | gz               |


Scenario: --update --keep-all-metadata --groupfile overrides old groupfile
Given I execute createrepo_c with args "--groupfile ../groupfile.xml ." in "/temp-repo"
  And I execute modifyrepo_c with args "../../custom_metadata.txt ." in "/temp-repo/repodata"
 When I execute createrepo_c with args "--update --keep-all-metadata --groupfile ../groupfile2.xml ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type            | File                               | Checksum Type | Compression Type |
      | primary         | ${checksum}-primary.xml.gz         | sha256        | gz               |
      | filelists       | ${checksum}-filelists.xml.gz       | sha256        | gz               |
      | other           | ${checksum}-other.xml.gz           | sha256        | gz               |
      | primary_db      | ${checksum}-primary.sqlite.bz2     | sha256        | bz2              |
      | filelists_db    | ${checksum}-filelists.sqlite.bz2   | sha256        | bz2              |
      | other_db        | ${checksum}-other.sqlite.bz2       | sha256        | bz2              |
      | group           | ${checksum}-groupfile2.xml         | sha256        | -                |
      | group_gz        | ${checksum}-groupfile2.xml.gz      | sha256        | gz               |
      | custom_metadata | ${checksum}-custom_metadata.txt.gz | sha256        | gz               |


# createrepo_c is compiled without support for zchunk on rhel 8 and 9
@not.with_os=rhel__ge__8
Scenario: --update --keep-all-metadata --groupfile overrides old groupfile and --zck generates zck versions
Given I execute createrepo_c with args "--groupfile ../groupfile.xml ." in "/temp-repo"
  And I execute modifyrepo_c with args "../../custom_metadata.txt ." in "/temp-repo/repodata"
 When I execute createrepo_c with args "--update --keep-all-metadata --groupfile ../groupfile2.xml --zck ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                                | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.gz          | sha256        | gz               |
      | primary_zck         | ${checksum}-primary.xml.zck         | sha256        | zck              |
      | filelists           | ${checksum}-filelists.xml.gz        | sha256        | gz               |
      | filelists_zck       | ${checksum}-filelists.xml.zck       | sha256        | zck              |
      | other               | ${checksum}-other.xml.gz            | sha256        | gz               |
      | other_zck           | ${checksum}-other.xml.zck           | sha256        | zck              |
      | primary_db          | ${checksum}-primary.sqlite.bz2      | sha256        | bz2              |
      | filelists_db        | ${checksum}-filelists.sqlite.bz2    | sha256        | bz2              |
      | other_db            | ${checksum}-other.sqlite.bz2        | sha256        | bz2              |
      | group               | ${checksum}-groupfile2.xml          | sha256        | -                |
      | group_gz            | ${checksum}-groupfile2.xml.gz       | sha256        | gz               |
      | group_zck           | ${checksum}-groupfile2.xml.zck      | sha256        | zck              |
      | custom_metadata     | ${checksum}-custom_metadata.txt.gz  | sha256        | gz               |
      | custom_metadata_zck | ${checksum}-custom_metadata.txt.zck | sha256        | zck              |


# createrepo_c is compiled without support for zchunk on rhel 8 and 9
@not.with_os=rhel__ge__8
Scenario: --update --keep-all-metadata keeps additional metadata including zck variants
Given I execute createrepo_c with args "--groupfile ../groupfile.xml --zck ." in "/temp-repo"
  And I execute modifyrepo_c with args "../../custom_metadata.txt --zck ." in "/temp-repo/repodata"
 When I execute createrepo_c with args "--update --keep-all-metadata ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                                | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.gz          | sha256        | gz               |
      | filelists           | ${checksum}-filelists.xml.gz        | sha256        | gz               |
      | other               | ${checksum}-other.xml.gz            | sha256        | gz               |
      | primary_db          | ${checksum}-primary.sqlite.bz2      | sha256        | bz2              |
      | filelists_db        | ${checksum}-filelists.sqlite.bz2    | sha256        | bz2              |
      | other_db            | ${checksum}-other.sqlite.bz2        | sha256        | bz2              |
      | group               | ${checksum}-groupfile.xml           | sha256        | -                |
      | group_gz            | ${checksum}-groupfile.xml.gz        | sha256        | gz               |
      | group_zck           | ${checksum}-groupfile.xml.zck       | sha256        | zck              |
      | custom_metadata     | ${checksum}-custom_metadata.txt.gz  | sha256        | gz               |
      | custom_metadata_zck | ${checksum}-custom_metadata.txt.zck | sha256        | zck              |


# Requires: https://github.com/rpm-software-management/createrepo_c/pull/268
#           https://github.com/rpm-software-management/createrepo_c/pull/276
@not.with_os=rhel__ge__8
Scenario: --update --keep-all-metadata keeps all additional metadata and merges new compressed modular metadata in
Given I execute createrepo_c with args "--groupfile ../groupfile.xml ." in "/temp-repo"
  And I execute modifyrepo_c with args "../../updateinfo.xml ." in "/temp-repo/repodata"
  And I execute modifyrepo_c with args "../../custom_metadata.txt ." in "/temp-repo/repodata"
  And I execute modifyrepo_c with args "../../modules.yaml ." in "/temp-repo/repodata"
  And I create "xz" compressed file "temp-repo/modules.yaml" with
      """
      ---
      document: modulemd
      version: 2
      data:
        name: test-module
        stream: "modular-package2"
        version: 2
        arch: x86_64
        description: Made up module
        summary: Test module
        license:
          module:
          - MIT
        profiles:
          test-profile2:
            rpms:
            - modular-package2
        components:
          rpms:
            modular-package2: {rationale: 'rationale for modular-package2'}
        artifacts:
          rpms:
          - modular-package2-0:0.1-1.x86_64.rpm
      ...
      """
 When I execute createrepo_c with args "--update --keep-all-metadata ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type            | File                               | Checksum Type | Compression Type |
      | primary         | ${checksum}-primary.xml.gz         | sha256        | gz               |
      | filelists       | ${checksum}-filelists.xml.gz       | sha256        | gz               |
      | other           | ${checksum}-other.xml.gz           | sha256        | gz               |
      | primary_db      | ${checksum}-primary.sqlite.bz2     | sha256        | bz2              |
      | filelists_db    | ${checksum}-filelists.sqlite.bz2   | sha256        | bz2              |
      | other_db        | ${checksum}-other.sqlite.bz2       | sha256        | bz2              |
      | group           | ${checksum}-groupfile.xml          | sha256        | -                |
      | group_gz        | ${checksum}-groupfile.xml.gz       | sha256        | gz               |
      | updateinfo      | ${checksum}-updateinfo.xml.gz      | sha256        | gz               |
      | custom_metadata | ${checksum}-custom_metadata.txt.gz | sha256        | gz               |
      | modules         | ${checksum}-modules.yaml.gz        | sha256        | gz               |
  And file "/temp-repo/repodata/[a-z0-9]*-modules.yaml.gz" contents is
      """
      ---
      document: modulemd
      version: 2
      data:
        name: test-module
        stream: "modular-package1"
        version: 1
        arch: x86_64
        summary: Test module
        description: >-
          Made up module
        license:
          module:
          - MIT
        profiles:
          test-profile1:
            rpms:
            - modular-package1
        components:
          rpms:
            modular-package1:
              rationale: rationale for modular-package1
        artifacts:
          rpms:
          - modular-package1-0:0.1-1.x86_64.rpm
      ...
      ---
      document: modulemd
      version: 2
      data:
        name: test-module
        stream: "modular-package2"
        version: 2
        arch: x86_64
        summary: Test module
        description: >-
          Made up module
        license:
          module:
          - MIT
        profiles:
          test-profile2:
            rpms:
            - modular-package2
        components:
          rpms:
            modular-package2:
              rationale: rationale for modular-package2
        artifacts:
          rpms:
          - modular-package2-0:0.1-1.x86_64.rpm
      ...
      """


@not.with_os=rhel__ge__8
Scenario: --update with --discard-additional-metadata doesn't keep additional module metadata
Given I execute createrepo_c with args "." in "/temp-repo"
  And I execute modifyrepo_c with args "../../modules.yaml ." in "/temp-repo/repodata"
 When I execute createrepo_c with args "--update --discard-additional-metadata ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type            | File                               | Checksum Type | Compression Type |
      | primary         | ${checksum}-primary.xml.gz         | sha256        | gz               |
      | filelists       | ${checksum}-filelists.xml.gz       | sha256        | gz               |
      | other           | ${checksum}-other.xml.gz           | sha256        | gz               |
      | primary_db      | ${checksum}-primary.sqlite.bz2     | sha256        | bz2              |
      | filelists_db    | ${checksum}-filelists.sqlite.bz2   | sha256        | bz2              |
      | other_db        | ${checksum}-other.sqlite.bz2       | sha256        | bz2              |


Scenario: --update keeps additional metadata by default
Given I execute createrepo_c with args "--groupfile ../groupfile.xml ." in "/temp-repo"
  And I execute modifyrepo_c with args "../../custom_metadata.txt ." in "/temp-repo/repodata"
 When I execute createrepo_c with args "--update ." in "/temp-repo"
 Then the exit code is 0
  And repodata "/temp-repo/repodata/" are consistent
  And repodata in "/temp-repo/repodata/" is
      | Type                | File                                | Checksum Type | Compression Type |
      | primary             | ${checksum}-primary.xml.gz          | sha256        | gz               |
      | filelists           | ${checksum}-filelists.xml.gz        | sha256        | gz               |
      | other               | ${checksum}-other.xml.gz            | sha256        | gz               |
      | primary_db          | ${checksum}-primary.sqlite.bz2      | sha256        | bz2              |
      | filelists_db        | ${checksum}-filelists.sqlite.bz2    | sha256        | bz2              |
      | other_db            | ${checksum}-other.sqlite.bz2        | sha256        | bz2              |
      | group               | ${checksum}-groupfile.xml           | sha256        | -                |
      | group_gz            | ${checksum}-groupfile.xml.gz        | sha256        | gz               |
      | custom_metadata     | ${checksum}-custom_metadata.txt.gz  | sha256        | gz               |
