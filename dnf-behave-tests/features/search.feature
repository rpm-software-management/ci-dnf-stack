Feature: Search command


Background:
  Given I use repository "dnf-ci-fedora"


Scenario: without keyword
   When I execute dnf with args "search"
   Then the exit code is 2
   And stderr contains "search: error: the following arguments are required: KEYWORD"


Scenario: with keyword
   When I execute dnf with args "search setup"
   Then the exit code is 0
   And stdout is
   """
   ======================== Name & Summary Matched: setup =========================
   setup.noarch : A set of system configuration and setup files
   setup.src : A set of system configuration and setup files
   """


@not.with_os=rhel__eq__8
@bz1742926
Scenario: with installed and availiable newest package doesn't duplicate results
   When I execute dnf with args "install setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | setup-0:2.12.1-1.fc29.noarch          |
   When I execute dnf with args "search setup"
   Then the exit code is 0
   And stdout is
   """
   ======================== Name & Summary Matched: setup =========================
   setup.noarch : A set of system configuration and setup files
   setup.src : A set of system configuration and setup files
   """


Scenario: with installed and availiable newest package and --showduplicates duplicates results
   When I execute dnf with args "install setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | setup-0:2.12.1-1.fc29.noarch          |
   When I execute dnf with args "search setup --showduplicates"
   Then the exit code is 0
   And stdout is
   """
   ======================== Name & Summary Matched: setup =========================
   setup-2.12.1-1.fc29.noarch : A set of system configuration and setup files
   setup-2.12.1-1.fc29.noarch : A set of system configuration and setup files
   setup-2.12.1-1.fc29.src : A set of system configuration and setup files
   """
