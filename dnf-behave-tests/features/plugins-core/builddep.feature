Feature: dnf builddep command


Background: Enable builddep plugin
  Given I enable plugin "builddep"
    And I use repository "dnf-ci-fedora"


Scenario: Dnf builddep can use spec file from a remote location
  Given I create directory "/remotedir"
    And I create file "/remotedir/pkg.spec" with
    """
    Name: pkg
    Version: 1
    Release: 1
    Summary: summary
    License: license

    BuildRequires: filesystem

    %description
    desc
    """
    And I set up a http server for directory "/remotedir"
   When I execute dnf with args "builddep http://localhost:{context.dnf.ports[/remotedir]}/pkg.spec"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |
