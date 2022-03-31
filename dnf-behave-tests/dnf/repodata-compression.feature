@dnf5
Feature: Repodata compression


@bz1914876
Scenario: Read repodata compressed with zstd
Given I configure a new repository "zstd-compressed-repodata" with
      | key    | value                                                           |
      |baseurl | {context.dnf.fixturesdir}/repos-static/zstd-compressed-repodata |
 When I execute dnf with args "repoquery zstd"
 Then the exit code is 0
  And stdout contains "zstd-0:1.4.7-1.fc34.noarch"
