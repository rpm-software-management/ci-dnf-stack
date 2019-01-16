Feature: Check when there is a package with missing dependency


Background: Force installation of an RPM without dependencies
   When I execute "rpm" with args "-i --root={context.dnf.installroot} --nodeps {context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/filesystem-3.9-2.fc29.x86_64.rpm"
   Then the exit code is 0


Scenario Outline: Check <option>
   When I execute dnf with args "check <option>"
   Then the exit code is 1
    And stdout contains "filesystem-3.9-2.fc29.x86_64 has missing requires of setup"
    And stderr is
        """
        Error: Check discovered 1 problem(s)
        """

Examples:
        | option             |
        # no option defaults to "all"
        |                    |
        | all                |
        | --dependencies     |


Scenario Outline: Check <option>
   When I execute dnf with args "check <option>"
   Then the exit code is 0
    And stdout is empty
    And stderr is empty

Examples:
        | option             |
        | --duplicates       |
        | --obsoleted        |
        | --provides         |
