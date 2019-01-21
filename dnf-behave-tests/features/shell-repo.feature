Feature: Shell repo


Scenario: Using dnf shell, enable repositories
   When I open dnf shell session
    And I execute in dnf shell "repo enable dnf-ci-fedora*"
    And I execute in dnf shell "repolist"
   Then stdout contains "dnf-ci-fedora"
    And stdout contains "dnf-ci-fedora-updates"
    And stdout contains "dnf-ci-fedora-updates-testing"
    And stdout does not contain "dnf-ci-thirdparty"
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"


Scenario: Using dnf shell, disable repositories
  Given I use the repository "dnf-ci-fedora"
    And I use the repository "dnf-ci-fedora-updates"
   When I open dnf shell session
    And I execute in dnf shell "repo disable dnf-ci-fedora-updates"
    And I execute in dnf shell "repolist"
   Then stdout contains "dnf-ci-fedora"
    And stdout does not contain "dnf-ci-fedora-updates"
    And stdout does not contain "dnf-ci-thirdparty"
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"


Scenario: Using dnf shell, disable and enable repositories
  Given I use the repository "dnf-ci-fedora"
    And I use the repository "dnf-ci-fedora-updates"
    And I use the repository "dnf-ci-fedora-updates-testing"
   When I open dnf shell session
    And I execute in dnf shell "repo disable dnf-ci-fedora-updates*"
    And I execute in dnf shell "repo enable dnf-ci-fedora-updates"
    And I execute in dnf shell "repolist"
   Then stdout contains "dnf-ci-fedora"
    And stdout contains "dnf-ci-fedora-updates"
    And stdout does not contain "dnf-ci-fedora-updates-testing"
    And stdout does not contain "dnf-ci-thirdparty"
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"
