Feature: Mark install


Scenario: Marking non-existing package for fails
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "mark install i-dont-exist"
   Then the exit code is 1


Scenario: Marking dependency as user-installed should not remove it automatically
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
   When I execute dnf with args "mark install setup"
   Then the exit code is 0
   When I execute dnf with args "remove filesystem"
   Then the exit code is 0
   And Transaction is following
        | Action        | Package                                   |
        | remove        | filesystem-0:3.9-2.fc29.x86_64            |
        | unchanged     | setup-0:2.12.1-1.fc29.noarch              |
   When I execute dnf with args "remove setup"
   Then the exit code is 0
   And Transaction is following
        | Action        | Package                                   |
        | remove        | setup-0:2.12.1-1.fc29.noarch              |
