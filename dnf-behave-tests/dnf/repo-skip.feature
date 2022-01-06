@bz2030652
Feature: do not skip repo sync when repo is not found


Background:
  Given I use repository "dnf-ci-fedora"
    And I use repository "non-existent-repo"


Scenario:
  Given I execute dnf with args "install not-a-pkg-1"
   Then the exit code is 1
    And stdout matches line by line
    """
    dnf-ci-fedora test repository                    \d{1,3} [Mk]?B/s |  \d{1,3} [Mk]?B     00:00
    non-existent-repo test repository               \d{1,3} [Mk]?B/s | \d{1,3}  [Mk]?B     00:00
    No match for argument: not-a-pkg-1
    """
    And stderr is
    """
    Error: Unable to find a match: not-a-pkg-1
    """
   When I execute dnf with args "install not-a-pkg-2"
   Then the exit code is 1
    And stdout matches line by line
    """
    dnf-ci-fedora test repository                    \d{1,3} [Mk]?B/s |  \d{1,3} [Mk]?B     00:00
    non-existent-repo test repository               \d{1,3} [Mk]?B/s | \d{1,3}  [Mk]?B     00:00
    No match for argument: not-a-pkg-2
    """
    And stderr is
    """
    Error: Unable to find a match: not-a-pkg-2
    """
