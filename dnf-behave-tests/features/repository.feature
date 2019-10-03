Feature: Handling local base url in repository in installroot


@fixture.httpd
Scenario: Handling remote base url in repository in installroot
  Given I use the http repository based on "dnf-ci-fedora"
    And I do not set config file
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | setup-0:2.12.1-1.fc29.noarch      |
        | install       | filesystem-0:3.9-2.fc29.x86_64    |
