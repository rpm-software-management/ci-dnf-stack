Feature: Pluginspath and pluginsconfpath test

Scenario: Redirect pluginspath
   When I execute dnf with args "download --help"
   Then the exit code is 0
   When I execute dnf with args "versionlock --help"
   Then the exit code is 0
  Given I configure dnf with
        | key        | value                                  |
        | pluginpath | {context.dnf.installroot}/test/plugins |
    And I create file "/test/plugins/download.py" with
    """
    import dnf.cli

    @dnf.plugin.register_command
    class DownloadCommand(dnf.cli.Command):
        aliases = ['download']
    """
   When I execute dnf with args "download --help"
   Then the exit code is 0
   When I execute dnf with args "versionlock --help"
   Then the exit code is 1
    And stderr contains "No such command: versionlock."


Scenario: Test default pluginsconfpath
  Given I do not disable plugins
   When I execute dnf with args "versionlock"
   Then the exit code is 0
# create versionlock.conf inside the installroot
  Given I create file "/etc/dnf/plugins/versionlock.conf" with
    """
    [main]
    enabled = 0
    """
# pluginconfpath is not related to installroot, so versionlock is not disabled
   When I execute dnf with args "versionlock"
   Then the exit code is 0


Scenario: Redirect pluginsconfpath in dnf.conf
  Given I do not disable plugins
   When I execute dnf with args "versionlock"
   Then the exit code is 0
  Given I configure dnf with
        | key            | value                                         |
        | pluginconfpath | {context.dnf.installroot}/test/pluginconfpath |
  Given I create file "/test/pluginconfpath/versionlock.conf" with
    """
    [main]
    enabled = 0
    """
    # pluginconfpath is now set in installroot, so versionlock is disabled
   When I execute dnf with args "versionlock"
   Then the exit code is 1
    And stderr contains "No such command: versionlock."

