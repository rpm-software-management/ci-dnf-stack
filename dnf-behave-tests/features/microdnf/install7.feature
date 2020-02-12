@no_installroot
Feature: Install package


Background:
Given I delete file "/etc/dnf/dnf.conf"
  And I delete file "/etc/yum.repos.d/*.repo" with globs
  And I delete directory "/var/lib/dnf/modulefailsafe/"


@bz1691353
Scenario: Install an RPM without null lines
  Given I use repository "dnf-ci-fedora"
   When I execute microdnf with args "install lame"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | install       | lame-0:3.100-4.fc29.x86_64                |
        | install       | lame-libs-0:3.100-4.fc29.x86_64           |
  And stdout does not contain "Installing: (null)"

