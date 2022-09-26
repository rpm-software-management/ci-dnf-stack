Feature: Tests createrepo_c with modular metedata


Background: Prepare modular metadata
Given I create file "/modules.yaml" with
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
      ---
      document: modulemd-defaults
      version: 1
      data:
        module: test-module
        stream: "modular-package1"
        profiles:
          test-profile1: [default]
      ...
      """
  And I create file "/stream.modulemd.yaml" with
      """
      ---
      document: modulemd
      version: 2
      data:
        name: test-module
        stream: "modular-package2"
        version: 1
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
      ---
      document: modulemd-defaults
      version: 1
      data:
        module: test-module
        stream: "modular-package2"
        profiles:
          test-profile2: [default]
      ...
      """
  And I create file "/some.modulemd-defaults.yaml" with
      """
      ---
      document: modulemd-defaults
      version: 1
      data:
        module: stratis
        stream: "1"
        profiles:
          1: [default]
      ...
      ---
      document: modulemd-defaults
      version: 1
      data:
        module: scala
        stream: "2.10"
        profiles:
          2.10: [default]
      ...
      """
 And I create file "/modular-result.yaml" with
      """
      ---
      document: modulemd-defaults
      version: 1
      data:
        module: scala
        stream: "2.10"
        profiles:
          2.10: [default]
      ...
      ---
      document: modulemd-defaults
      version: 1
      data:
        module: stratis
        stream: "1"
        profiles:
          1: [default]
      ...
      ---
      document: modulemd-defaults
      version: 1
      data:
        module: test-module
        profiles:
          test-profile1: [default]
          test-profile2: [default]
      ...
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
        version: 1
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


Scenario: modular metadata located in repository are added to repodata
Given I create directory "/empty_repo/"
  And I copy file "{context.scenario.default_tmp_dir}/modules.yaml" to "/empty_repo"
 When I execute createrepo_c with args "." in "/empty_repo"
 Then the exit code is 0
  And stderr is empty
  And repodata "/empty_repo/repodata/" are consistent
  And repodata in "/empty_repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |
      | modules      | ${checksum}-modules.yaml.gz      | sha256        | gz               |


Scenario: modular metadata are added to repository with a package
Given I create directory "/repo/"
  And I copy file "{context.scenario.default_tmp_dir}/modules.yaml" to "/repo"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/modular-package1-0.1-1.x86_64.rpm" to "/repo"
 When I execute createrepo_c with args "." in "/repo"
 Then the exit code is 0
  And stderr is empty
  And repodata "/repo/repodata/" are consistent
  And repodata in "/repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |
      | modules      | ${checksum}-modules.yaml.gz      | sha256        | gz               |


Scenario: multiple modular metadata are merged
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/modular-package1-0.1-1.x86_64.rpm" to "/"
 When I execute createrepo_c with args "." in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |
      | modules      | ${checksum}-modules.yaml.gz      | sha256        | gz               |
  And the text file contents of "/repodata/[a-z0-9]*-modules.yaml.gz" and "/modular-result.yaml" do not differ


Scenario: modular metadata located in repository in subdirectories are added to repodata
Given I create directory "/repo/"
Given I create directory "/repo/a"
Given I create directory "/repo/a/b"
  And I copy file "{context.scenario.default_tmp_dir}/modules.yaml" to "/repo/a/b/"
  And I copy file "{context.scenario.default_tmp_dir}/stream.modulemd.yaml" to "/repo/a/"
  And I copy file "{context.scenario.default_tmp_dir}/some.modulemd-defaults.yaml" to "/repo/"
 When I execute createrepo_c with args "." in "/repo"
 Then the exit code is 0
  And stderr is empty
  And repodata "/repo/repodata/" are consistent
  And repodata in "/repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |
      | modules      | ${checksum}-modules.yaml.gz      | sha256        | gz               |
  And the text file contents of "/repo/repodata/[a-z0-9]*-modules.yaml.gz" and "/modular-result.yaml" do not differ


Scenario: modular metadata are added to repodata with pkglist
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/modular-package1-0.1-1.x86_64.rpm" to "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/modular-package2-0.1-1.x86_64.rpm" to "/"
  And I create file "/list" with
      """
      modular-package1-0.1-1.x86_64.rpm
      some.modulemd-defaults.yaml
      modules.yaml
      stream.modulemd.yaml
      """
 When I execute createrepo_c with args "--pkglist {context.scenario.default_tmp_dir}/list ." in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |
      | modules      | ${checksum}-modules.yaml.gz      | sha256        | gz               |
  And the text file contents of "/repodata/[a-z0-9]*-modules.yaml.gz" and "/modular-result.yaml" do not differ
  And primary in "/repodata" has only packages
      | Name             | Epoch | Version | Release | Architecture |
      | modular-package1 | 0     | 0.1     | 1       | x86_64       |


Scenario: modular metadata are added to repodata with pkglist when running with absolute path
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/modular-package1-0.1-1.x86_64.rpm" to "/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/modular-package2-0.1-1.x86_64.rpm" to "/"
  And I create file "/list" with
      """
      modular-package1-0.1-1.x86_64.rpm
      some.modulemd-defaults.yaml
      modules.yaml
      stream.modulemd.yaml
      """
 When I execute createrepo_c with args "--pkglist {context.scenario.default_tmp_dir}/list {context.scenario.default_tmp_dir}/" in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/repodata/" are consistent
  And repodata in "/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |
      | modules      | ${checksum}-modules.yaml.gz      | sha256        | gz               |
  And the text file contents of "/repodata/[a-z0-9]*-modules.yaml.gz" and "/modular-result.yaml" do not differ
  And primary in "/repodata" has only packages
      | Name             | Epoch | Version | Release | Architecture |
      | modular-package1 | 0     | 0.1     | 1       | x86_64       |


# Requires: https://github.com/rpm-software-management/createrepo_c/pull/268
#           https://github.com/rpm-software-management/createrepo_c/pull/276
@not.with_os=rhel__ge__8
Scenario: using pkglist with invalid paths
Given I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/modular-package1-0.1-1.x86_64.rpm" to "/"
  And I create file "/list" with
      """
      modular-package1-0.1-1.x86_64.rpm
      invalid-not-existing.modulemd-defaults.yaml
      modules.yaml
      stream.modulemd.yaml
      """
 When I execute createrepo_c with args "--pkglist {context.scenario.default_tmp_dir}/list ." in "/"
 Then the exit code is 1
  And stderr is
      """
      Critical: Could not load module index file invalid-not-existing.modulemd-defaults.yaml: Cannot open invalid-not-existing.modulemd-defaults.yaml: File invalid-not-existing.modulemd-defaults.yaml doesn't exists or not a regular file
      """


Scenario: modular metadata located in repository are added to repodata with specified compression
Given I create directory "/empty_repo/"
  And I copy file "{context.scenario.default_tmp_dir}/modules.yaml" to "/empty_repo"
 When I execute createrepo_c with args ". --compress-type xz" in "/empty_repo"
 Then the exit code is 0
  And stderr is empty
  And repodata "/empty_repo/repodata/" are consistent
  And repodata in "/empty_repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |
      | primary_db   | ${checksum}-primary.sqlite.xz    | sha256        | xz               |
      | filelists_db | ${checksum}-filelists.sqlite.xz  | sha256        | xz               |
      | other_db     | ${checksum}-other.sqlite.xz      | sha256        | xz               |
      | modules      | ${checksum}-modules.yaml.xz      | sha256        | xz               |


Scenario: modular metadata located in repository override present metadata on --update and --discard-additional-metadata
Given I create directory "/repo/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/modular-package1-0.1-1.x86_64.rpm" to "/repo"
  And I copy file "{context.scenario.default_tmp_dir}/modules.yaml" to "/repo"
  And I execute createrepo_c with args "." in "/repo"
  And repodata "/repo/repodata/" are consistent
  And I delete file "/repo/modules.yaml"
  And I copy file "{context.scenario.default_tmp_dir}/some.modulemd-defaults.yaml" to "/repo/some.modulemd-defaults.yaml"
 When I execute createrepo_c with args ". --update --discard-additional-metadata" in "/repo"
 Then the exit code is 0
  And stderr is empty
  And repodata "/repo/repodata/" are consistent
  And repodata in "/repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |
      | modules      | ${checksum}-modules.yaml.gz      | sha256        | gz               |
  And file "/repo/repodata/[a-z0-9]*-modules.yaml.gz" contents is
      """
      ---
      document: modulemd-defaults
      version: 1
      data:
        module: scala
        stream: "2.10"
        profiles:
          2.10: [default]
      ...
      ---
      document: modulemd-defaults
      version: 1
      data:
        module: stratis
        stream: "1"
        profiles:
          1: [default]
      ...
      """


Scenario: modular metadata located in repository get merged with present metadata on --update --keep-all-metadata
Given I create directory "/repo/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/modular-package1-0.1-1.x86_64.rpm" to "/repo"
  And I copy file "{context.scenario.default_tmp_dir}/modules.yaml" to "/repo"
  And I execute createrepo_c with args "." in "/repo"
  And repodata "/repo/repodata/" are consistent
  And I delete file "/repo/modules.yaml"
  And I copy file "{context.scenario.default_tmp_dir}/some.modulemd-defaults.yaml" to "/repo/some.modulemd-defaults.yaml"
  And I copy file "{context.scenario.default_tmp_dir}/stream.modulemd.yaml" to "/repo/stream.modulemd.yaml"
 When I execute createrepo_c with args ". --update --keep-all-metadata" in "/repo"
 Then the exit code is 0
  And stderr is empty
  And repodata "/repo/repodata/" are consistent
  And repodata in "/repo/repodata/" is
      | Type         | File                             | Checksum Type | Compression Type |
      | primary      | ${checksum}-primary.xml.gz       | sha256        | gz               |
      | filelists    | ${checksum}-filelists.xml.gz     | sha256        | gz               |
      | other        | ${checksum}-other.xml.gz         | sha256        | gz               |
      | primary_db   | ${checksum}-primary.sqlite.bz2   | sha256        | bz2              |
      | filelists_db | ${checksum}-filelists.sqlite.bz2 | sha256        | bz2              |
      | other_db     | ${checksum}-other.sqlite.bz2     | sha256        | bz2              |
      | modules      | ${checksum}-modules.yaml.gz      | sha256        | gz               |
  And the text file contents of "/modular-result.yaml" and "/repo/repodata/[a-z0-9]*-modules.yaml.gz" do not differ


@bz1906831
Scenario: Using invalid modular metadata doesn't leave temp .repodata directory
Given I create directory "/repo/"
  And I create file "repo/modules.yaml" with
      """
      invalid modular metadata file
      """
 When I execute createrepo_c with args "." in "/repo"
 Then the exit code is 1
  And file "/repo/.repodata" does not exist


# Requires: https://github.com/rpm-software-management/createrepo_c/pull/268
#           https://github.com/rpm-software-management/createrepo_c/pull/276
@not.with_os=rhel__ge__8
Scenario: Using file with an unknown compressions is an error
Given I create directory "/repo/"
  And I execute "head -c 100 < /dev/urandom > {context.scenario.default_tmp_dir}/repo/modules.yaml.magck"
 When I execute createrepo_c with args "." in "/repo"
 Then the exit code is 1
  And file "/repo/.repodata" does not exist
  And stderr is
      """
      Critical: Could not load module index file ./modules.yaml.magck: Cannot open ./modules.yaml.magck: Cannot detect compression type
      """
