Feature: Repolist with enabled/disabled repositories

  @setup
  Scenario: Feature Setup
      Given empty repository "TestA"
        And empty repository "TestB"
        And repository "TestC" with packages
         | Package | Tag | Value |
         | TestA   |     |       |
         | TestB   |     |       |
         | TestC   |     |       |
       When I enable repository "TestB"
        And I enable repository "TestC"
        And I successfully run "dnf makecache"

  Scenario: Repolist without arguments
       When I successfully run "dnf repolist"
       Then the command stdout should match regexp "repo id +repo name +status\s+TestB +TestB +0\s+TestC +TestC +3"

  Scenario: Repolist with "enabled"
       When I successfully run "dnf repolist enabled"
       Then the command stdout should match regexp "repo id +repo name +status\s+TestB +TestB +0\s+TestC +TestC +3"

  Scenario: Repolist with "disabled"
       When I successfully run "dnf repolist disabled"
       Then the command stdout should match regexp "repo id +repo name\s+TestA +TestA"

  Scenario: Repolist with "all"
       When I successfully run "dnf repolist all"
       Then the command stdout should match regexp "repo id +repo name +status\s+TestA +TestA +disabled\s+TestB +TestB +enabled: 0\s+TestC +TestC +enabled: 3"
