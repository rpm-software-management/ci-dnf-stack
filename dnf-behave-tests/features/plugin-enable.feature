Feature: Plugin enablement by config file and command line option


Background:
Given I do not disable plugins


Scenario: Verify that debuginfo-install plugin is enabled
 When I execute dnf with args "-v repolist"
 Then stdout contains "Loaded plugins:.* debuginfo-install.*"


Scenario: Disable enabled debuginfo-install plugin from command line
 When I execute dnf with args "-v repolist --disableplugin=debuginfo-install"
 Then stdout does not contain "Loaded plugins:.* debuginfo-install.*"


Scenario: Disable debuginfo-install plugin by config file
Given I create file "/etc/dnf/plugins/debuginfo-install.conf" with
  """
  [main]
  enabled=0
  """
  And I configure dnf with
      | key            | value                                     |
      | pluginconfpath | {context.dnf.installroot}/etc/dnf/plugins |
 When I execute dnf with args "-v repolist"
 Then stdout does not contain "Loaded plugins:.* debuginfo-install.*"


@bz1614539
Scenario: Enable disabled debuginfo-install plugin from command line
Given I create file "/etc/dnf/plugins/debuginfo-install.conf" with
  """
  [main]
  enabled=0
  """
  And I configure dnf with
      | key            | value                                     |
      | pluginconfpath | {context.dnf.installroot}/etc/dnf/plugins |
 When I execute dnf with args "-v repolist --enableplugin=debuginfo-install"
 Then stdout contains "Loaded plugins:.* debuginfo-install.*"
