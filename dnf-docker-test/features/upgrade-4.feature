@bz1659390
Feature: Print additional information about skipped packages after the transaction with best=0

  @setup
  Scenario: Testing repository and defaults setup
     Given repository "base" with packages
          | Package      | Tag      | Value  |
          | TestA        | Version  | 1      |
          | TestA v2     | Version  | 2      |
          | TestA v3     | Version  | 3      |
          |              | Requires | TestR  |
      When I enable repository "base"
       And I successfully run "dnf makecache"

  Scenario: Print information about shipped packages
     Given I successfully run "dnf -y install TestA-1-1"
      When I save rpmdb
       And I run "dnf -y update --setopt 'best=0'"
      Then rpmdb changes are
          | State     | Packages  |
          | updated   | TestA/2-1 |
       And the command stdout section "Upgrading:" should match regexp "TestA +noarch +2-1"
       And the command stdout section "Skipping packages with broken dependencies:" should match regexp "TestA +noarch +3-1"
       And the command stdout section "Upgraded:" should match regexp "TestA-2-1.noarch"
       And the command stdout section "Skipped:" should match regexp "TestA-3-1.noarch"
