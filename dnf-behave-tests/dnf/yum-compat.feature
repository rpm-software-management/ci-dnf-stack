Feature: Testing aliased/depricated commands compatible with yum


Background:
Given I use repository "simple-base"


# @dnf5
# TODO(nsella) Unknown argument "install-n" for command "microdnf"
Scenario: install using install-n
 When I execute dnf with args "install-n labirinto"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |


# @dnf5
# TODO(nsella) Unknown argument "install-n" for command "microdnf"
@bz1821524
Scenario: using install-n doesn't allow additional NEVRA parts
 When I execute dnf with args "install-n labirinto.x86_64"
 Then the exit code is 1
  And stdout is
      """
      No match for argument: labirinto.x86_64
        * Maybe you meant: labirinto
      """
  And stderr is
      """
      <REPOSYNC>
      Error: Unable to find a match: labirinto.x86_64
      """


# @dnf5
# TODO(nsella) Unknown argument "install-na" for command "microdnf"
Scenario: install using install-na
 When I execute dnf with args "install-na labirinto.x86_64"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |


# @dnf5
# TODO(nsella) Unknown argument "install-na" for command "microdnf"
@bz1821524
Scenario: using install-na doesn't allow additional nevra parts
 When I execute dnf with args "install-na labirinto-1.0-1.fc29.x86_64"
 Then the exit code is 1
  And stdout is
      """
      No match for argument: labirinto-1.0-1.fc29.x86_64
        * Maybe you meant: labirinto
      """
  And stderr is
      """
      <REPOSYNC>
      Error: Unable to find a match: labirinto-1.0-1.fc29.x86_64
      """


# @dnf5
# TODO(nsella) Unknown argument "install-nevra" for command "microdnf"
Scenario: install using install-nevra
 When I execute dnf with args "install-nevra labirinto-0:1.0-1.fc29.x86_64"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |


# @dnf5
# TODO(nsella) Unknown argument "install-nevra" for command "microdnf"
Scenario: install using install-nevra doesn't work without full nevra
 When I execute dnf with args "install-nevra labirinto-1.0-1.fc29"
 Then the exit code is 1
  And stdout is
      """
      No match for argument: labirinto-1.0-1.fc29
        * Maybe you meant: labirinto
      """
  And stderr is
      """
      <REPOSYNC>
      Error: Unable to find a match: labirinto-1.0-1.fc29
      """


# @dnf5
# TODO(nsella) Unknown argument "localinstall" for command "microdnf"
Scenario: install using localinstall
 When I execute dnf with args "localinstall {context.scenario.repos_location}/simple-base/x86_64/labirinto-1.0-1.fc29.x86_64.rpm"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |


# @dnf5
# TODO(nsella) Unknown argument "localinstall" for command "microdnf"
@bz1821524
Scenario: install using localinstall fails with just available package name
 When I execute dnf with args "localinstall labirinto"
 Then the exit code is 1
  And stderr is
      """
      <REPOSYNC>
      """
  And stdout is
      """
      Not a valid rpm file path: labirinto
      """


# @dnf5
# TODO(nsella) Unknown argument "remove-n" for command "microdnf"
Scenario: remove using remove-n
Given I successfully execute dnf with args "install labirinto"
 When I execute dnf with args "remove-n labirinto"
 Then the exit code is 0
  And Transaction is following
      | Action       | Package                       |
      | remove       | labirinto-0:1.0-1.fc29.x86_64 |


# @dnf5
# TODO(nsella) Unknown argument "remove-n" for command "microdnf"
@bz1821524
Scenario: remove using remove-n doesn't allow additional NEVRA parts
Given I successfully execute dnf with args "install labirinto"
 When I execute dnf with args "remove-n labirinto-1.0"
 Then the exit code is 0
  And Transaction is empty
  And Stdout is
      """
      No match for argument: labirinto-1.0
      Dependencies resolved.
      Nothing to do.
      Complete!
      """


# @dnf5
# TODO(nsella) Unknown argument "repoquery-n" for command "microdnf"
Scenario: using repoquery-n
 When I execute dnf with args "repoquery-n labirinto"
 Then the exit code is 0
  And Stdout is
      """
      labirinto-0:1.0-1.fc29.src
      labirinto-0:1.0-1.fc29.x86_64
      """


# @dnf5
# TODO(nsella) Unknown argument "repoquery-n" for command "microdnf"
@bz1821524
Scenario: remove using repoquery-n doesn't allow additional NEVRA parts
 When I execute dnf with args "repoquery-n labirinto-1.0"
 Then the exit code is 0
  And Stdout is empty
