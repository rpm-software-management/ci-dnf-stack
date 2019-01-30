Feature: Repolist with --enablerepo and --disablerepo


# Disabling repositories when there is no match results only in warning, whereas enabling results in error/warning depending on the "strict" option
#   --disablerepo  strict=true   -> warning
#   --disablerepo  strict=false  -> warning
#   --enablerepo   strict=true   -> error
#   --enablerepo   strict=false  -> warning


Background: Do not add --disablerepo='*' to the dnf command by default
  Given I do not disable all repos


Scenario: List repositories with --enablerepo='*' when there are no repo files - strict
  Given There are no repositories
   When I execute dnf with args "repolist --enablerepo='*' --setopt=strict=true"
   Then the exit code is 1
    And stderr contains "Error: Unknown repo: '*'"


Scenario: List repositories with --enablerepo='*' when there are no repo files - not strict
  Given There are no repositories
   When I execute dnf with args "repolist --enablerepo='*' --setopt=strict=false"
   Then the exit code is 0
    And stderr contains "No repositories available"


Scenario: List repositories with --disablerepo='*' when there are no repo files - strict
  Given There are no repositories
   When I execute dnf with args "repolist --disablerepo='*' --setopt=strict=true"
   Then the exit code is 0
    And stderr contains "No repositories available"


Scenario: List repositories with --disablerepo='*' when there are no repo files - not strict
  Given There are no repositories
   When I execute dnf with args "repolist --disablerepo='*' --setopt=strict=false"
   Then the exit code is 0
    And stderr contains "No repositories available"

