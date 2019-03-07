Feature: Pluginspath and pluginsconfpath test

Background: Enable plugins
  Given I enable plugin "download"
    And I enable plugin "versionlock"
   When I execute dnf with args "download --help"
   Then the exit code is 0
   When I execute dnf with args "versionlock --help"
   Then the exit code is 0
    

@wip
Scenario: Redirect pluginspath
  Given I do not set config file
    And I create and substitute file "/etc/dnf/dnf.conf" with
    """
    [main]
    pluginpath={context.dnf.installroot}/test/plugins
    """
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

