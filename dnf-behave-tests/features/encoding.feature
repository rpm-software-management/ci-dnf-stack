Feature: Test encoding


Scenario: UTF-8 characters in .repo filename
  Given I do not set config file
    And I create file "/etc/dnf/dnf.conf" with
        """
        [main]
        reposdir=/testrepos
        """
    And I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key     | value                                            |
        | baseurl | {context.scenario.repos_location}/dnf-ci-fedora  |
    And I copy file "{context.dnf.installroot}/testrepos/testrepo.repo" to "testrepos/ř.repo"
    And I delete file "/testrepos/testrepo.repo"
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "testrepo\s+testrepo test repository"
    And stderr is empty


@not.with_os=rhel__eq__8
@bz1803038
Scenario: non-UTF-8 characters in .repo filename
  Given I do not set config file
    And I create file "/etc/dnf/dnf.conf" with
        """
        [main]
        reposdir=/testrepos
        """
    And I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key     | value                                            |
        | baseurl | {context.scenario.repos_location}/dnf-ci-fedora  |
    And I copy file "{context.dnf.installroot}/testrepos/testrepo.repo" to "testrepos/{context.dnf.invalid_utf8_char}.repo"
    And I delete file "/testrepos/testrepo.repo"
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout is empty
    And stderr is
        """
        Warning: failed loading '{context.dnf.installroot}/testrepos/\udcfd.repo', skipping.
        No repositories available
        """
