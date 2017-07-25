Feature: DNF/Behave test (pluginspath and pluginsconfpath test)

Scenario: Test host default pluginsconfpath (/etc/dnf/plugins/)
  Given _deprecated I use the repository "test-1"
  When _deprecated I create a file "/etc/dnf/plugins/debuginfo-install.conf" with content: "[main]\nenabled=1\nautoupdate=0"
  When _deprecated I create a file "/etc/yum.repos.d/test-1.repo" with content: "[test-1]\nname=test-1\nbaseurl=file:///var/www/html/repo/test-1-gpg\nenabled=1\ngpgcheck=0\n\n[test-1-debuginfo]\nname=test-1-debuginfo\nbaseurl=file:///var/www/html/repo/test-1\nenabled=0\ngpgcheck=0"
  Then _deprecated I execute "dnf" command "-y debuginfo-install TestA" with "success"
  And _deprecated transaction changes are as follows
   | State        | Packages                 |
   | installed    | TestA-debuginfo-1.0.0-1  |
  When _deprecated I create a file "/etc/yum.repos.d/test-1.repo" with content: "[upgrade_1]\nname=upgrade_1\nbaseurl=file:///var/www/html/repo/upgrade_1-gpg\nenabled=1\ngpgcheck=0\n\n[upgrade_1-debuginfo]\nname=upgrade_1-debuginfo\nbaseurl=file:///var/www/html/repo/upgrade_1\nenabled=0\ngpgcheck=0"
  Then _deprecated I execute "dnf" command "-y upgrade" with "success"
  And _deprecated transaction changes are as follows
   | State        | Packages         |
   | present      | TestA-debuginfo  |
  When _deprecated I create a file "/etc/dnf/plugins/debuginfo-install.conf" with content: "[main]\nenabled=1\nautoupdate=1"
  Then _deprecated I execute "dnf" command "-y upgrade" with "success"
  And _deprecated transaction changes are as follows
   | State        | Packages                 |
   | upgraded     | TestA-debuginfo-1.0.0-2  |
# Reset to original state
  When _deprecated I execute "dnf" command "-y remove TestA-debuginfo" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages         |
   | removed      | TestA-debuginfo  |
  When _deprecated I create a file "/etc/dnf/plugins/debuginfo-install.conf" with content: "[main]\nenabled=1\nautoupdate=0"
