@no_installroot
Feature: microdnf install command on packages


Background:
Given I delete file "/etc/dnf/dnf.conf"
  And I delete file "/etc/yum.repos.d/*.repo" with globs
  And I delete directory "/var/lib/dnf/modulefailsafe/"


@bz1734350
Scenario: Install packages from remote repodata with remote packages
#5. remote repo with remote packages
Given I use repository "dnf-ci-fedora" as http
 When I execute microdnf with args "remove lame"
 When I execute microdnf with args "install lame"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                                   |
      | install       | lame-0:3.100-4.fc29.x86_64                |
      | install       | lame-libs-0:3.100-4.fc29.x86_64           |
