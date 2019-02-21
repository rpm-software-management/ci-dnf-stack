Feature: Plugin enablement by config file and command line option

Scenario: Verify that debuginfo-install plugin is enabled
    When I successfully run "dnf -v repolist"
    Then the command stdout should match regexp "Loaded plugins:.* debuginfo-install.*"

Scenario: Disable enabled debuginfo-install plugin from command line
    When I successfully run "dnf -v repolist --disableplugin=debuginfo-install"
    Then the command stdout should not match regexp "Loaded plugins:.* debuginfo-install.*"

Scenario: Disable debuginfo-install plugin by config file
    When I successfully run "sed -i 's/enabled=1/enabled=0/' /etc/dnf/plugins/debuginfo-install.conf"
     And I successfully run "dnf -v repolist"
    Then the command stdout should not match regexp "Loaded plugins:.* debuginfo-install.*"

@bz1614539
Scenario: Enable disabled debuginfo-install plugin from command line
    When I successfully run "dnf -v repolist --enableplugin=debuginfo-install"
    Then the command stdout should match regexp "Loaded plugins:.* debuginfo-install.*"
