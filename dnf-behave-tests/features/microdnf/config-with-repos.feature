# no bug, PR https://github.com/rpm-software-management/libdnf/pull/882
@not.with_os=rhel__eq__8
@no_installroot
Feature: Repositories configured in main configuration file


Background: Configure repositories in the main configuration file
  Given I delete file "/etc/dnf/dnf.conf"
    And I delete file "/etc/yum.repos.d/*.repo" with globs
    And I delete directory "/var/lib/dnf/modulefailsafe/"
    And I create file "/etc/dnf/dnf.conf" with
     """
     [main]
     gpgcheck = 0
     
     [repo-A]
     name = repo-A test repository
     enabled = 1
     baseurl = http://url.xyz
     
     [repo-B]
     name = repo-B test repository
     enabled = 0
     baseurl = http://url.xyz
     
     [repo-C]
     name = repo-C test repository
     enabled = 1
     baseurl = http://url.xyz
     """


Scenario: Repositories configured only in the main configuration file
   When I execute microdnf with args "repolist --all"
   Then the exit code is 0
    And stdout is
     """
     repo id repo name                status
     repo-A  repo-A test repository  enabled
     repo-B  repo-B test repository disabled
     repo-C  repo-C test repository  enabled
     """


Scenario: Repositories configured in the main configuration file and in *.repo files
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates" with configuration
        | key     | value |
        | enabled | 0     |
   When I execute microdnf with args "repolist --all"
   Then the exit code is 0
    And stdout is
     """
     repo id               repo name                               status
     dnf-ci-fedora         dnf-ci-fedora test repository          enabled
     dnf-ci-fedora-updates dnf-ci-fedora-updates test repository disabled
     repo-A                repo-A test repository                 enabled
     repo-B                repo-B test repository                disabled
     repo-C                repo-C test repository                 enabled
     """
