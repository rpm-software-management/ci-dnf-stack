Feature: Enabling module streams - error handling


Background:
  Given I use the repository "dnf-ci-fedora-modular-updates"


Scenario: Fail to enable a different stream of an already enabled module
   When I execute dnf with args "module enable nodejs:8"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package            |
        | module-stream-enable     | nodejs:8           |
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
   When I execute dnf with args "module enable nodejs:10"
   Then the exit code is 1
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
        | nodejs    | enabled   | 8         |           |
    And stderr contains "The operation would result in switching of module 'nodejs' stream '8' to stream '10'"
    And stderr contains "Error: It is not possible to switch enabled streams of a module."


Scenario: Fail to enable a module stream when specifying only module
   When I execute dnf with args "module enable nodejs"
   Then the exit code is 1
    And Transaction is empty
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
    And stderr is
        """
        Cannot enable more streams from module 'nodejs' at the same time
        Unable to resolve argument nodejs
        Error: Problems in request:
        broken groups or modules: nodejs

        """


@bz1629655
Scenario: Fail to enable a module stream when specifying wrong version
   When I execute dnf with args "module enable nodejs:8:99"
   Then the exit code is 1
    And Transaction is empty
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
    And stderr is
        """
        Error: Problems in request:
        missing groups or modules: nodejs:8:99

        """


@bz1629655
Scenario: Fail to enable a non-existent module stream
   When I execute dnf with args "module enable nodejs:1"
   Then the exit code is 1
    And Transaction is empty
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
    And stderr is
        """
        Error: Problems in request:
        missing groups or modules: nodejs:1

        """


Scenario: Fail to enable a module stream when not specifying anything
   When I execute dnf with args "module enable"
   Then the exit code is 1
    And Transaction is empty
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
    And stderr is
        """
        Error: dnf module enable: too few arguments

        """


@bz1581267
Scenario: Fail to enable a module stream when specifying more streams of the same module
   When I execute dnf with args "module enable nodejs:8 nodejs:10"
   Then the exit code is 1
    And Transaction is empty
    And modules state is following
        | Module    | State     | Stream    | Profiles  |
    And stderr is
        """
        Cannot enable multiple streams for module 'nodejs'
        Unable to resolve argument nodejs:10
        Error: Problems in request:
        broken groups or modules: nodejs:10

        """
