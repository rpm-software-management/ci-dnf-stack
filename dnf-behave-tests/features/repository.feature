Feature: Handling local base url in repository in installroot

Scenario: Handling local base url in repository in installroot
  Given I use the repository "testrepo"
    And I do not set config file
    And I do not set reposdir
    And I create file "/etc/yum.repos.d/test.repo" with
    """
    [testrepo]
    name=testrepo
    baseurl=file://$DNF0/repos/dnf-ci-fedora
    enabled=1
    gpgcheck=0
    """
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | setup-0:2.12.1-1.fc29.noarch      |
        | install       | filesystem-0:3.9-2.fc29.x86_64    |
