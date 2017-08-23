Feature: Test for repoquery weak deps related functionality,
  options --recommends, --supplements, --suggests, --enhances, 
  --whatrecommends, --whatsupplements, --whatsuggests, --whatenhances, --repo

  @setup
  Scenario: Feature Setup
      Given repository "base" with packages
        | Package | Tag       | Value |
        | TestA   | Version   | 1     |
        |         | Release   | 1     |
        |         | Recommends  | TestB |
        |         | Supplements | TestC |
        |         | Suggests    | TestD |
        |         | Enhances    | TestE |

  Scenario: repoquery --recommends (when there is no such capability)
       When I run "dnf repoquery --recommends TestA"
       Then the command stdout should not match regexp "Test"

  Scenario: repoquery --recommends (when there is such capability in listed repo)
       When I run "dnf repoquery --recommends TestA --repo base"
       Then the command stdout should match regexp "TestB"
        And the command stdout should not match regexp "Test[ACDE]"

  Scenario: repoquery --recommends (when there is such capability)
       When I enable repository "base"
        And I run "dnf repoquery --recommends TestA"
       Then the command stdout should match regexp "TestB"
        And the command stdout should not match regexp "Test[ACDE]"

  Scenario: repoquery --supplements (when there is no such capability)
       When I disable repository "base"
        And I run "dnf repoquery --supplements TestA"
       Then the command stdout should not match regexp "Test"

  Scenario: repoquery --supplements (when there is such capability in listed repo)
       When I run "dnf repoquery --supplements TestA --repo base"
       Then the command stdout should match regexp "TestC"
        And the command stdout should not match regexp "Test[ABDE]"

  Scenario: repoquery --supplements (when there is such capability)
       When I enable repository "base"
        And I run "dnf repoquery --supplements TestA"
       Then the command stdout should match regexp "TestC"
        And the command stdout should not match regexp "Test[ABDE]"

  Scenario: repoquery --suggests (when there is no such capability)
       When I disable repository "base"
        And I run "dnf repoquery --suggests TestA"
       Then the command stdout should not match regexp "Test"

  Scenario: repoquery --suggests (when there is such capability in listed repo)
       When I run "dnf repoquery --suggests TestA --repo base"
       Then the command stdout should match regexp "TestD"
        And the command stdout should not match regexp "Test[ABCE]"

  Scenario: repoquery --suggests (when there is such capability)
       When I enable repository "base"
        And I run "dnf repoquery --suggests TestA"
       Then the command stdout should match regexp "TestD"
        And the command stdout should not match regexp "Test[ABCE]"

  Scenario: repoquery --enhances (when there is no such capability)
       When I disable repository "base"
        And I run "dnf repoquery --enhances TestA"
       Then the command stdout should not match regexp "Test"

  Scenario: repoquery --enhances (when there is such capability in listed repo)
       When I run "dnf repoquery --enhances TestA --repo base"
       Then the command stdout should match regexp "TestE"
        And the command stdout should not match regexp "Test[ABCD]"

  Scenario: repoquery --enhances (when there is such capability)
       When I enable repository "base"
        And I run "dnf repoquery --enhances TestA"
       Then the command stdout should match regexp "TestE"
        And the command stdout should not match regexp "Test[ABCD]"

  Scenario: repoquery --whatrecommends (when there is no such pkg)
       When I disable repository "base"
        And I run "dnf repoquery --whatrecommends TestB"
       Then the command stdout should not match regexp "Test"

  Scenario: repoquery --whatrecommends (when there is such pkg in listed repo)
       When I run "dnf repoquery --whatrecommends TestB --repo base"
       Then the command stdout should match regexp "TestA-0:1-1.noarch"
        And the command stdout should not match regexp "Test[BCDE]"

  Scenario: repoquery --whatrecommends (when there is such pkg)
       When I enable repository "base"
        And I run "dnf repoquery --whatrecommends TestB"
       Then the command stdout should match regexp "TestA-0:1-1.noarch"
        And the command stdout should not match regexp "Test[BCDE]"

  Scenario: repoquery --whatsupplements (when there is no such pkg)
       When I disable repository "base"
        And I run "dnf repoquery --whatsupplements TestC"
       Then the command stdout should not match regexp "Test"

  Scenario: repoquery --whatsupplements (when there is such pkg in listed repo)
       When I run "dnf repoquery --whatsupplements TestC --repo base"
       Then the command stdout should match regexp "TestA-0:1-1.noarch"
        And the command stdout should not match regexp "Test[BCDE]"

  Scenario: repoquery --whatsupplements (when there is such pkg)
       When I enable repository "base"
        And I run "dnf repoquery --whatsupplements TestC"
       Then the command stdout should match regexp "TestA-0:1-1.noarch"
        And the command stdout should not match regexp "Test[BCDE]"

  Scenario: repoquery --whatsuggests (when there is no such pkg)
       When I disable repository "base"
        And I run "dnf repoquery --whatsuggests TestD"
       Then the command stdout should not match regexp "Test"

  Scenario: repoquery --whatsuggests (when there is such pkg in listed repo)
       When I run "dnf repoquery --whatsuggests TestD --repo base"
       Then the command stdout should match regexp "TestA-0:1-1.noarch"
        And the command stdout should not match regexp "Test[BCDE]"

  Scenario: repoquery --whatsuggests (when there is such pkg)
       When I enable repository "base"
        And I run "dnf repoquery --whatsuggests TestD"
       Then the command stdout should match regexp "TestA-0:1-1.noarch"
        And the command stdout should not match regexp "Test[BCDE]"

  Scenario: repoquery --whatenhances (when there is no such pkg)
       When I disable repository "base"
        And I run "dnf repoquery --whatenhances TestE"
       Then the command stdout should not match regexp "Test"

  Scenario: repoquery --whatenhances (when there is such pkg in listed repo)
       When I run "dnf repoquery --whatenhances TestE --repo base"
       Then the command stdout should match regexp "TestA-0:1-1.noarch"
        And the command stdout should not match regexp "Test[BCDE]"

  Scenario: repoquery --whatenhances (when there is such pkg)
       When I enable repository "base"
        And I run "dnf repoquery --whatenhances TestE"
       Then the command stdout should match regexp "TestA-0:1-1.noarch"
        And the command stdout should not match regexp "Test[BCDE]"
