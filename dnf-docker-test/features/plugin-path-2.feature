Feature: DNF/Behave test (pluginspath and pluginsconfpath test)

Scenario: Redirect installroot pluginspath
  Given _deprecated I use the repository "test-1"
  When _deprecated I execute "dnf" command "--installroot=/dockertesting download TestA" with "success"
  And _deprecated I execute "dnf" command "--installroot=/dockertesting config-manager" with "success"
  When _deprecated I copy plugin module "download.py" from default plugin path into "/test/plugins2"
  And _deprecated I create a file "/dockertesting/etc/dnf/dnf.conf" with content: "[main]\npluginpath=/test/plugins2"
  Then _deprecated I execute "dnf" command "--installroot=/dockertesting download TestA" with "success"
  And _deprecated I execute "dnf" command "--installroot=/dockertesting config-manager" with "fail"
  When _deprecated I create a file "/etc/dnf/dnf.conf" with content: "[main]"
