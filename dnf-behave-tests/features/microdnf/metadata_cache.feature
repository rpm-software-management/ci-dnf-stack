Feature: microdnf can use repository metadata cache

@bz1771147
Scenario: Microdnf respects metadata_expire
Given I use repository "simple-base" as http
 When I execute microdnf with args "repoquery labirinto"
 Then the exit code is 0
  And stdout is
  """
  Downloading metadata...
  labirinto-1.0-1.fc29.src
  labirinto-1.0-1.fc29.x86_64
  """
 # since libdnf measures the metadata file age in whole seconds, wait till it changes
 When I sleep for "1" seconds
  And I execute microdnf with args "repoquery labirinto"
 Then the exit code is 0
  And stdout is
  """
  labirinto-1.0-1.fc29.src
  labirinto-1.0-1.fc29.x86_64
  """
 When I execute microdnf with args "--refresh repoquery labirinto"
 Then the exit code is 0
  And stdout is
  """
  Downloading metadata...
  labirinto-1.0-1.fc29.src
  labirinto-1.0-1.fc29.x86_64
  """
