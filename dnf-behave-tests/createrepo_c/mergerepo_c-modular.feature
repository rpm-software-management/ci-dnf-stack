Feature: Tests mergerepo_c with modular repositories


Background: Prepare two modular repositories
Given I create directory "/modular_repo1/"
  And I create directory "/modular_repo2/"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/modular-package1-0.1-1.x86_64.rpm" to "/modular_repo1"
  And I copy file "{context.scenario.repos_location}/createrepo_c-ci-packages/x86_64/modular-package2-0.1-1.x86_64.rpm" to "/modular_repo2"
  And I execute createrepo_c with args "." in "/modular_repo1"
  And I execute createrepo_c with args "." in "/modular_repo2"
  And I create file "/modules1.yaml" with
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
  And I create file "/modules2.yaml" with
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
  And I execute modifyrepo_c with args "--mdtype=modules ../../modules1.yaml ." in "/modular_repo1/repodata"
  And I execute modifyrepo_c with args "--mdtype=modules ../../modules2.yaml ." in "/modular_repo2/repodata"


Scenario: merged repository contains streams from both source repositories
 When I execute mergerepo_c with args "--repo {context.scenario.default_tmp_dir}/modular_repo1 --repo {context.scenario.default_tmp_dir}/modular_repo2" in "/"
 Then the exit code is 0
  And stderr is empty
  And repodata "/merged_repo/repodata/" are consistent
  And file "/merged_repo/repodata/[a-z0-9]*-modules.yaml.gz" contents is
      """
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
