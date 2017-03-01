Feature: Enabling and disabling a repository in dnf shell

Scenario: Enabling and disabling a repository in dnf shell
     Given repository "TestRepoA" with packages
          | Package | Tag | Value |
          | TestA   |     |       |
       And repository "TestRepoB" with packages
          | Package | Tag | Value |
          | TestB   |     |       |
       And I have dnf shell session opened with parameters "-y"
      When I run dnf shell command "repository enable TestRepo\*"
       And I run dnf shell command "repolist"
      Then the command stdout should match regexp "TestRepoA.*\n.*TestRepoB"

      When I run dnf shell command "repository disable TestRepoA"
       And I run dnf shell command "repolist"
      Then the command stdout should match regexp "TestRepoB"
       And the command stdout should not match regexp "TestRepoA"

      When I run dnf shell command "repo disable TestRepo\*"
       And I run dnf shell command "repo enable TestRepoA"
       And I run dnf shell command "repolist"
      Then the command stdout should match regexp "TestRepoA"
       And the command stdout should not match regexp "TestRepoB"
