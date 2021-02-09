Feature: Protected packages


@not.wit_os=rhel__eq__8
Scenario: Package protected via "protected_packages" option cannot be removed
  Given I configure dnf with
        | key                       | value            |
        | protected_packages        | filesystem       |
    And I use repository "dnf-ci-fedora"
    # "/usr" directory is needed to load rpm database (to overcome bad heuristics in libdnf created by Colin Walters)
    And I create directory "/usr"
    And I execute microdnf with args "install filesystem"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |
   When I execute microdnf with args "remove filesystem"
   Then the exit code is 1
    And stderr contains "Problem: The operation would result in removing the following protected packages: filesystem"
