Feature: Advisory aplicability on a modular system

@setup
Scenario: setup
  Given repository "base" with packages
        | Package           | Tag       | Value |
        | module/Test v10   | Version   | 10.6  |
        |                   | Release   | 1     |
        | module/Test v9    | Version   | 9.6.8 |
        |                   | Release   | 1     |
    And repository "updates" with packages
        | Package           | Tag       | Value |
        | module/Test       | Version   | 10.7  |
        |                   | Release   | 1     |
    And updateinfo defined in repository "updates"
        | Id            | Tag           | Value                                     |
        | RHEA-2018:101 | Title         | Test enhancement                          |
        |               | Type          | enhancement                               |
        |               | Description   | Miss Moneypenny's nails needs polishing   |
        |               | Solution      | Apply the red fingernail polish           |
        |               | Summary       | Miss Moneypenny's nails should be red     |
        |               | Severity      | Low                                       |
        |               | Rights        | Beauty salon license                      |
        |               | Issued        | 2019-01-07 00:00:00                       |
        |               | Updated       | 2019-01-20 22:26:32                       |
        |               | Reference     | BZ12345                                   |
        |               | Module        | test-module:10:2:6c81f848:noarch          |
        |               | Package       | Test-10.7-1.module                        |
    And a file "modules.yaml" with type "modules" added into repository "base"
        """
        ---
        document: modulemd
        version: 2
        data:
          name: test-module
          stream: 9
          version: 1
          context: 6c81f848
          arch: noarch
          summary: Test module
          description: >-
            Test is an advanced Object-Relational database management system (DBMS).
          license:
            module:
            - MIT
            content:
            - MIT
          profiles:
            client:
              rpms:
              - Test
          artifacts:
            rpms:
            - Test-0:9.6.8-1.module.noarch
        ...
        ---
        document: modulemd
        version: 2
        data:
          name: test-module
          stream: 10
          version: 1
          context: 6c81f848
          arch: noarch
          summary: PostgreSQL module
          description: >-
            Test is an advanced Object-Relational database management system (DBMS).
          license:
            module:
            - MIT
            content:
            - MIT
          profiles:
            client:
              rpms:
              - Test
          artifacts:
            rpms:
            - Test-0:10.6-1.module.noarch
        ...
        ---
        document: modulemd-defaults
        version: 1
        data:
            module: test-module
            stream: 9
            profiles:
              9: [client]
              10: [client]
        ...
        """
    And a file "modules.yaml" with type "modules" added into repository "updates"
        """
        ---
        document: modulemd
        version: 2
        data:
          name: test-module
          stream: 10
          version: 2
          context: 6c81f848
          arch: noarch
          summary: PostgreSQL module
          description: >-
            Test is an advanced Object-Relational database management system (DBMS).
          license:
            module:
            - MIT
            content:
            - MIT
          profiles:
            client:
              rpms:
              - Test
          artifacts:
            rpms:
            - Test-0:10.7-1.module.noarch
        ...
        """


@bz1622614
Scenario: List available updates for installed streams (updates available)
  When I enable repository "base"
   And I successfully run "dnf -y module install test-module:10"
  When I enable repository "updates"
   And I successfully run "dnf updateinfo --list"
  Then the command stdout should match regexp "RHEA-2018:101 enhancement Test-10.7-1.module.noarch"


Scenario: Cleanup from previous scenario
  When I successfully run "dnf -y module remove test-module:10"
   And I successfully run "dnf -y module reset test-module"
   And I disable repository "updates"


# this scenario is failing on upstream, but should pass on lates RHEL8
@xfail
@bz1622614
Scenario: Updates for non-enabled streams are hidden
  When I successfully run "dnf -y module install test-module:9"
   And I enable repository "updates"
   And I successfully run "dnf updateinfo --list"
  Then the command stdout should not match regexp "RHEA-2018:101 enhancement Test-10.7-1.module.noarch"
