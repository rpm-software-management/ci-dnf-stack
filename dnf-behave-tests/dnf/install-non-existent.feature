Feature: Test for installation of non-existent rpm or package


@dnf5
@bz1578369
Scenario: Try to install a non-existent rpm
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install non-existent.rpm"
   Then the exit code is 1
    And dnf4 stderr contains "Can not load RPM file"
    And dnf4 stderr contains "Could not open"
    And dnf5 stderr is
    """
    Failed to access RPM "non-existent.rpm": No such file or directory
    """


@dnf5
Scenario: Try to install a non-existent package
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install non-existent-package"
   Then the exit code is 1
    And dnf4 stdout contains "No match for argument"
    And dnf4 stderr contains "Error: Unable to find a match"
    And dnf5 stdout is
    """
    <REPOSYNC>
    """
    And dnf5 stderr is
    """
    Failed to resolve the transaction:
    No match for argument: non-existent-package
    """


@dnf5
@bz1717429
Scenario: Install an existent and an non-existent package
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install setup non-existent-package"
   Then the exit code is 1
    And dnf4 stdout contains "No match for argument: non-existent-package"
    And dnf4 stderr contains "Error: Unable to find a match: non-existent-package"
    And dnf5 stdout is
    """
    <REPOSYNC>
    """
    And dnf5 stderr is
    """
    Failed to resolve the transaction:
    No match for argument: non-existent-package
    """


@dnf5
@bz1717429
Scenario: Install an existent and an non-existent package with --skip-broken
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install setup non-existent-package --skip-broken"
   Then the exit code is 0
    And stdout contains "No match for argument: non-existent-package"
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
