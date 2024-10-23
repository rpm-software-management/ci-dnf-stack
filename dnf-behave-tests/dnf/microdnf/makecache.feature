@dnf5
Feature: makecache command


Scenario: Create a metadata cache using "makecache" and then test that "repoquery" does not download metadata
  Given I use repository "dnf-ci-fedora" as http
  When I execute microdnf with args "makecache"
  Then the exit code is 0
  And stderr matches line by line
      """
      Updating and loading repositories:
      dnf-ci-fedora test repository .*
      Repositories loaded.
      """
  When I execute microdnf with args "repoquery nodejs"
  Then the exit code is 0
   And stdout is
      """
      nodejs-1:5.12.1-1.fc29.src
      nodejs-1:5.12.1-1.fc29.x86_64
      """
  And stderr is
      """
      Updating and loading repositories:
      Repositories loaded.
      """


Scenario: Tests that "repoquery" downloads metadata (creates a cache) and then "makecache" does not download metadada
  Given I use repository "dnf-ci-fedora" as http
  When I execute microdnf with args "repoquery nodejs"
  Then the exit code is 0
  And stderr matches line by line
      """
      Updating and loading repositories:
      dnf-ci-fedora test repository .*
      Repositories loaded.
      """
   And stdout is
      """
      nodejs-1:5.12.1-1.fc29.src
      nodejs-1:5.12.1-1.fc29.x86_64
      """
  When I execute microdnf with args "makecache"
  Then the exit code is 0
   And stdout is
      """
      Metadata cache created.
      """
   And stderr is
      """
      Updating and loading repositories:
      Repositories loaded.
      """


Scenario: makecache with skip_if_unavailable=0 repo doesn't succeed
Given I configure a new repository "non-existent" with
      | key                 | value                               |
      | baseurl             | https://www.not-available-repo.com/ |
      | enabled             | 1                                   |
      | skip_if_unavailable | 0                                   |
 When I execute microdnf with args "makecache"
 Then the exit code is 1
  And stdout is empty
  And stderr contains "Updating and loading repositories:"
  And stderr contains "non-existent test repository"
  And stderr contains "Failed to download metadata \(baseurl: \"https://www.not-available-repo.com/\"\) for repository \"non-existent\""
