Feature: microdnf install command on packages


@bz1771012
Scenario: Install package with --nodocs option from local repodata with local packages
Given I use repository "microdnf-install-nodocs"
  And I execute microdnf with args "--nodocs install man-pages"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                                   |
      | install       | man-pages-0:4.16-3.fc29.x86_64            |
  And file "/usr/share/doc/man-pages/README" does not exist

