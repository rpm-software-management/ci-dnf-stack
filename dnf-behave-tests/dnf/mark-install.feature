Feature: Mark install


# @dnf5
# TODO(nsella) Unknown argument "mark" for command "microdnf"
Scenario: Marking non-existing package for fails
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "mark install i-dont-exist"
   Then the exit code is 1


# @dnf5
# TODO(nsella) Unknown argument "mark" for command "microdnf"
Scenario: Marking dependency as user-installed should not remove it automatically
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
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

@bz2046581
Scenario: Marking installed package when history DB is not on the system (deleted or not created yet)
   When I execute rpm with args "-i {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/wget-1.19.6-5.fc29.x86_64.rpm"
   Then the exit code is 0
    And package reasons are
        | Package                      | Reason         |
        | wget-1.19.6-5.fc29.x86_64    | unknown        |
   When I execute dnf with args "mark install wget"
   Then the exit code is 0
    And package reasons are
        | Package                      | Reason        |
        | wget-1.19.6-5.fc29.x86_64    | user          |
