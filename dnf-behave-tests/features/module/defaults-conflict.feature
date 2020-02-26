Feature: Not fail if conflicts in module metadata.

  @bz1656019
  Scenario: Enabling two repository with conflicting defaults - only remove defaults
    Given I use repository "dnf-ci-thirdparty-modular-updates"
      And I use repository "dnf-ci-thirdparty-modular-updates-conflict"
     When I execute dnf with args "module list"
     Then the exit code is 0
      And module list is
      | Repository                        | Name        | Stream     | Profiles |
      | dnf-ci-thirdparty-modular-updates | cookbook    | 1          | ham-and-eggs, orange-juice, axe-soup |
      | dnf-ci-thirdparty-modular-updates | ingredience | chicken    | default |
      | dnf-ci-thirdparty-modular-updates | ingredience | egg        | default |
      | dnf-ci-thirdparty-modular-updates | ingredience | orange     | default |
      | dnf-ci-thirdparty-modular-updates | ingredience | strawberry | default |
      | dnf-ci-thirdparty-modular-updates-conflict | ingredience | chicken| default |
      | dnf-ci-thirdparty-modular-updates-conflict | ingredience | egg    | default |
      | dnf-ci-thirdparty-modular-updates-conflict | ingredience | orange | default |

     When I execute dnf with args "module list --disablerepo=dnf-ci-thirdparty-modular-updates-conflict"
     Then the exit code is 0
      And module list is
      | Repository                        | Name        | Stream     | Profiles |
      | dnf-ci-thirdparty-modular-updates | cookbook    | 1          | ham-and-eggs, orange-juice, axe-soup |
      | dnf-ci-thirdparty-modular-updates | ingredience | chicken    | default |
      | dnf-ci-thirdparty-modular-updates | ingredience | egg        | default |
      | dnf-ci-thirdparty-modular-updates | ingredience | orange [d] | default |
      | dnf-ci-thirdparty-modular-updates | ingredience | strawberry | default |

     When I execute dnf with args "module list --disablerepo=dnf-ci-thirdparty-modular-updates"
     Then the exit code is 0
      And module list is
      | Repository                                 | Name        | Stream      | Profiles|
      | dnf-ci-thirdparty-modular-updates-conflict | ingredience | chicken [d] | default |
      | dnf-ci-thirdparty-modular-updates-conflict | ingredience | egg         | default |
      | dnf-ci-thirdparty-modular-updates-conflict | ingredience | orange      | default |


Scenario: Two streams that have matching NSVCA but different content (conflict) are dropped by libmodulemd, but defaults are unaffected
Given I use repository "dnf-ci-thirdparty-modular-updates"
  And I use repository "dnf-ci-thirdparty-modular-updates-duplicate"
 When I execute dnf with args "module list"
 Then the exit code is 0
  And module list is
      | Repository                                  | Name        | Stream     | Profiles                             |
      | dnf-ci-thirdparty-modular-updates           | cookbook    | 1          | ham-and-eggs, orange-juice, axe-soup |
      | dnf-ci-thirdparty-modular-updates           | ingredience | chicken    | default                              |
      | dnf-ci-thirdparty-modular-updates           | ingredience | egg        | default                              |
      | dnf-ci-thirdparty-modular-updates           | ingredience | orange [d] | default                              |
      | dnf-ci-thirdparty-modular-updates           | ingredience | strawberry | default                              |
      | dnf-ci-thirdparty-modular-updates-duplicate | ingredience | egg        | default                              |
