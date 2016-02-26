Feature: DNF/Behave test (pluginspath and pluginsconfpath test)

Scenario: Redirect installroot pluginsconfpath in dnf.conf (path redirected into installroot)
  Given I use the repository "test-1"
  When I create a file "/dockertesting3/test/pluginconfpath/debuginfo-install.conf" with content: "[main]\nenabled=1\nautoupdate=0"
  When I create a file "/test/pluginconfpath/debuginfo-install.conf" with content: "[main]\nenabled=1\nautoupdate=1"
  When I create a file "/etc/dnf/plugins/debuginfo-install.conf" with content: "[main]\nenabled=1\nautoupdate=0"
  When I create a file "/dockertesting3/etc/yum.repos.d/test-1.repo" with content: "[test-1]\nname=test-1\nbaseurl=file:///var/www/html/repo/test-1-gpg\nenabled=1\ngpgcheck=0\n\n[test-1-debuginfo]\nname=test-1-debuginfo\nbaseurl=file:///var/www/html/repo/test-1\nenabled=0\ngpgcheck=0"
  Then I execute "dnf" command "--installroot=/dockertesting3 -y debuginfo-install TestB" with "success"
  And I execute "bash" command "rpm -q --root=/dockertesting3 TestB-debuginfo" with "success"
  And line from "stdout" should "start" with "TestB-debuginfo-1.0.0-1"
  When I create a file "/dockertesting3/etc/yum.repos.d/test-1.repo" with content: "[upgrade_1]\nname=upgrade_1\nbaseurl=file:///var/www/html/repo/upgrade_1-gpg\nenabled=1\ngpgcheck=0\n\n[upgrade_1-debuginfo]\nname=upgrade_1-debuginfo\nbaseurl=file:///var/www/html/repo/upgrade_1\nenabled=0\ngpgcheck=0"
  Then I execute "dnf" command "--installroot=/dockertesting3 -y upgrade" with "success"
  And I execute "bash" command "rpm -q --root=/dockertesting3 TestB-debuginfo" with "success"
  And line from "stdout" should "start" with "TestB-debuginfo-1.0.0-1"
  When I create a file "/dockertesting3/etc/dnf/dnf.conf" with content: "[main]\npluginconfpath=/test/pluginconfpath"
  Then I execute "dnf" command "--installroot=/dockertesting3 -y upgrade" with "success"
  And I execute "bash" command "rpm -q --root=/dockertesting3 TestB-debuginfo" with "success"
  And line from "stdout" should "start" with "TestB-debuginfo-1.0.0-2"
