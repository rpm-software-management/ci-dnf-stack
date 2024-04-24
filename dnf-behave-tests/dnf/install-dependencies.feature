@dnf5
Feature: Tests for install with dependencies


@bz1774617
Scenario: Best candidates have conflicting dependencies
  Given I use repository "install-dependencies"
   When I execute dnf with args "install foo bar --no-best"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | foo-0:1.0-1.fc29.x86_64           |
        | install       | bar-0:1.0-1.fc29.x86_64           |
        | install-dep   | lib-0:1.0-1.fc29.x86_64           |
        | conflict      | lib-0:2.0-1.fc29.x86_64           |
        | broken        | foo-0:2.0-1.fc29.x86_64           |
    And stderr contains "cannot install both lib-.\.0-1\.fc29\.x86_64 and lib-.\.0-1\.fc29\.x86_64"
    And stderr contains "package foo-2.0-1.fc29.x86_64 requires lib-2.0, but none of the providers can be installed"
    And stderr contains "package bar-1.0-1.fc29.x86_64 requires lib-1.0, but none of the providers can be installed"
    And stderr contains "cannot install the best candidate for the job"
    And stderr contains "conflicting requests"
