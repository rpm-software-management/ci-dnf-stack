@dnf5
Feature: Repoquery tests working with files

@RHEL-5747
Scenario: filter by file in primary.xml but force command only search in rpm names -> empty output
Given I use repository "repoquery-files"
 When I execute dnf with args "repoquery-n /usr/bin/a-binary"
 Then the exit code is 0
  And stdout is
      """
      <REPOSYNC>
      """

