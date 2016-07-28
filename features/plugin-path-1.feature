Feature: DNF/Behave test (pluginspath and pluginsconfpath test)

Scenario: Redirect host pluginspath
  Given I use the repository "test-1"
  When I execute "dnf" command "download TestA" with "success"
  And I execute "dnf" command "copr list rpmsoftwaremanagement" with "success"
  When I copy plugin module "download.py" from default plugin path into "/test/plugins"
  And I create a file "/etc/dnf/dnf.conf" with content: "[main]\npluginpath=/test/plugins"
  Then I execute "dnf" command "download TestA" with "success"
  And I execute "dnf" command "copr list rpmsoftwaremanagement" with "fail"
  When I copy plugin module "copr.py" from default plugin path into "/test/plugins"
  Then I execute "dnf" command "copr list rpmsoftwaremanagement" with "success"
  When I create a file "/etc/dnf/dnf.conf" with content: "[main]"
