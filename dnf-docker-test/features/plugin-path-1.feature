Feature: DNF/Behave test (pluginspath and pluginsconfpath test)

Scenario: Redirect host pluginspath
  Given _deprecated I use the repository "test-1"
  When _deprecated I execute "dnf" command "download TestA" with "success"
  And _deprecated I execute "dnf" command "config-manager --help" with "success"
  When _deprecated I copy plugin module "download.py" from default plugin path into "/test/plugins"
  And _deprecated I create a file "/etc/dnf/dnf.conf" with content: "[main]\npluginpath=/test/plugins"
  Then _deprecated I execute "dnf" command "download TestA" with "success"
  And _deprecated I execute "dnf" command "config-manager" with "fail"
  When _deprecated I copy plugin module "config_manager.py" from default plugin path into "/test/plugins"
  Then _deprecated I execute "dnf" command "config-manager" with "success"
  When _deprecated I create a file "/etc/dnf/dnf.conf" with content: "[main]"
