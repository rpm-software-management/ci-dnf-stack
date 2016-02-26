Feature: DNF/Behave test (pluginspath and pluginsconfpath test)

Scenario: Test host default pluginsconfpath (/etc/dnf/plugins/)
  Given I use the repository "test-1"
  When I create a file "/etc/dnf/plugins/debuginfo-install.conf" with content: "[main]\nenabled=1\nautoupdate=0"
  When I create a file "/etc/yum.repos.d/test-1.repo" with content: "[test-1]\nname=test-1\nbaseurl=file:///var/www/html/repo/test-1-gpg\nenabled=1\ngpgcheck=0\n\n[test-1-debuginfo]\nname=test-1-debuginfo\nbaseurl=file:///var/www/html/repo/test-1\nenabled=0\ngpgcheck=0"
  Then I execute "dnf" command "-y debuginfo-install TestA" with "success"
  And package "TestA-debuginfo-1.0.0-1" should be "installed"
  When I create a file "/etc/yum.repos.d/test-1.repo" with content: "[upgrade_1]\nname=upgrade_1\nbaseurl=file:///var/www/html/repo/upgrade_1-gpg\nenabled=1\ngpgcheck=0\n\n[upgrade_1-debuginfo]\nname=upgrade_1-debuginfo\nbaseurl=file:///var/www/html/repo/upgrade_1\nenabled=0\ngpgcheck=0"
  Then I execute "dnf" command "-y upgrade" with "success"
  And package "TestA-debuginfo" should be "unupgraded"
  When I create a file "/etc/dnf/plugins/debuginfo-install.conf" with content: "[main]\nenabled=1\nautoupdate=1"
  Then I execute "dnf" command "-y upgrade" with "success"
  And package "TestA-debuginfo-1.0.0-2" should be "upgraded"
# Reset to original state
  When I execute "dnf" command "-y remove TestA-debuginfo" with "success"
  Then package "TestA-debuginfo" should be "removed"
  When I create a file "/etc/dnf/plugins/debuginfo-install.conf" with content: "[main]\nenabled=1\nautoupdate=0"
