@dnf5daemon
@destructive
Feature: Test dnf5daemon-client initialization


Scenario: Run dnf5daemon-client install when dbus is stopped
  Given I stop dbus
   When I execute dnf5daemon-client with args "repoquery"
   Then the exit code is 1
    And stderr is
    """
    Failed to open bus (No such file or directory)
    Is D-Bus daemon running?
    """


Scenario: Run dnf5daemon-client with no args when dbus is stopped
  Given I stop dbus
   When I execute dnf5daemon-client with no args
   Then the exit code is 2


Scenario: Run dnf5daemon-client install when polkitd is stopped
  Given I stop polkitd
   When I execute dnf5daemon-client with args "repoquery rpm"
   Then the exit code is 1
    And stderr is
    """
    Failed to open bus (No such file or directory)
    Is D-Bus daemon running?
    """


Scenario: Run dnf5daemon-client with no args when polkitd is stopped
  Given I stop polkitd
   When I execute dnf5daemon-client with no args
   Then the exit code is 2

