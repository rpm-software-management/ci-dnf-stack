Feature: microdnf install command on packages


Scenario: Install a documentation package from local repodata
Given I use repository "microdnf-install-nodocs"
 When I execute microdnf with args "install man-pages"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                                   |
      | install       | man-pages-0:4.16-3.fc29.x86_64            |
  And file "/usr/share/doc/man-pages/README" exists

