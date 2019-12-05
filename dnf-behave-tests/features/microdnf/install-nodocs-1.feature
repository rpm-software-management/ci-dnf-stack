@no_installroot
Feature: microdnf install command on packages


Background:
Given I delete file "/etc/dnf/dnf.conf"
  And I delete file "/etc/yum.repos.d/*.repo" with globs


Scenario: Install a documentation package from local repodata
Given I use repository "microdnf-install-nodocs"
 When I execute microdnf with args "install man-pages"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                                   |
      | install       | man-pages-0:4.16-3.fc29.x86_64            |
  And file "/usr/share/doc/man-pages/README" exists

