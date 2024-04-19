@dnf5
Feature: Repoquery tests working with files


Scenario: list files in an rpm including files in filelists.xml
Given I use repository "repoquery-files"
 When I execute dnf with args "repoquery a.x86_64 -l"
 Then the exit code is 0
  And stdout is
      """
      <REPOSYNC>
      /root-file
      /usr/bin/a-binary
      """


Scenario: filter by file in primary.xml
Given I use repository "repoquery-files"
 When I execute dnf with args "repoquery --file /usr/bin/a-binary"
 Then the exit code is 0
  And stdout is
      """
      <REPOSYNC>
      a-0:1.0-1.fc29.x86_64
      """


@bz2276012
Scenario: filter by file in filelists.xml
Given I use repository "repoquery-files"
 When I execute dnf with args "repoquery --file /root-file"
 Then the exit code is 0
  And stdout is
      """
      <REPOSYNC>
      a-0:1.0-1.fc29.x86_64
      """
