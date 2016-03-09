Feature: DNF/Behave test (DNF config and config files in installroot)

Scenario: Create dnf.conf file and test if host is using /etc/dnf/dnf.conf.
  Given I use the repository "test-1"
  When I execute "dnf" command "install -y TestC" with "success"
  Then package "TestC" should be "installed"
  When I create a file "/etc/dnf/dnf.conf" with content: "[main]\nexclude=TestA"
  When I execute "dnf" command "install -y TestA" with "fail"
  Then package "TestA, TestB" should be "absent"
  # Cleaning traces from scenario - dnf.conf with only main section
  When I execute "dnf" command "remove -y TestC" with "success"
  Then package "TestC" should be "removed"
  When I create a file "/etc/dnf/dnf.conf" with content: "[main]"

Scenario: Test removal of depemdency when clean_requirements_on_remove=false
  Given I use the repository "test-1"
  When I create a file "/etc/dnf/dnf.conf" with content: "[main]\nexclude=TestA\nclean_requirements_on_remove=false"
  When I execute "dnf" command "install -y --disableexclude=main TestA" with "success"
  Then package "TestA, TestB" should be "installed"
  When I execute "dnf" command "remove -y --disableexclude=all TestA" with "success"
  Then package "TestA" should be "removed"
  When I execute "dnf" command "remove -y TestB" with "success"
  Then package "TestB" should be "removed"
  # Cleaning traces from scenario - dnf.conf with only main section
  When I create a file "/etc/dnf/dnf.conf" with content: "[main]"

Scenario: Create dnf.conf file and test if host is taking option -c /test/dnf.conf file (absolute and relative path)
  Given I use the repository "test-1"
  When I create a file "/etc/dnf/dnf.conf" with content: "[main]\nexclude=TestA\nclean_requirements_on_remove=false"
  When I create a file "/test/dnf.conf" with content: "[main]\nexclude=TestD\nclean_requirements_on_remove=true"
  When I execute "dnf" command "install -y -c /test/dnf.conf TestA" with "success"
  Then package "TestA, TestB" should be "installed"
  When I execute "dnf" command "install -y -c /test/dnf.conf TestD" with "fail"
  When I execute "dnf" command "install -y --config test/dnf.conf TestD" with "fail"
# TestA cannot be removed due to host exclude in dnf.conf
  When I execute "dnf" command "remove -y TestA" with "fail"
# TestB can be removed because TestA that is installed and require TestB was excluded
  When I execute "dnf" command "remove -y TestB" with "success"
  Then package "TestA, TestB" should be "removed"

Scenario: Test without dnf.conf in installroot (dnf.conf is not taken from host)
  Given I use the repository "test-1"
  When I create a file "/test/dnf.conf" with content: "[main]\nexclude=TestD\nclean_requirements_on_remove=true"
  When I create a file "/etc/dnf/dnf.conf" with content: "[main]\nexclude=TestA\nclean_requirements_on_remove=true"
  When I execute "dnf" command "config-manager --setopt=reposdir=/dockertesting/etc/yum.repos.d --add-repo /etc/yum.repos.d/test-1.repo" with "success"
  Then the path "/dockertesting/etc/yum.repos.d/test-1.repo" should be "present"
  And the path "/dockertesting/etc/dnf/dnf.conf" should be "absent"
  When I execute "dnf" command "--installroot=/dockertesting -y install TestA" with "fail"
  When I execute "bash" command "rpm -q --root=/dockertesting TestA" with "fail"
  When I create a file "/etc/dnf/dnf.conf" with content: "[main]\nclean_requirements_on_remove=true"
  When I execute "dnf" command "--installroot=/dockertesting -y install TestA" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestA" with "success"
  Then line from "stdout" should "start" with "TestA-1.0.0-1."

Scenario: Test with dnf.conf in installroot (dnf.conf is taken from installroot)
  Given I use the repository "test-1"
  When I create a file "/dockertesting/etc/dnf/dnf.conf" with content: "[main]\nexclude=TestE"
  Then the path "/dockertesting/etc/dnf/dnf.conf" should be "present"
  When I execute "dnf" command "--installroot=/dockertesting -y install TestE" with "fail"
  When I execute "bash" command "rpm -q --root=/dockertesting TestE" with "fail"

Scenario: Test with dnf.conf in installroot and --config (dnf.conf is taken from --config)
  Given I use the repository "test-1"
  When I create a file "/dockertesting/etc/dnf/dnf.conf" with content: "[main]\nexclude=TestE"
  When I create a file "/test/dnf.conf" with content: "[main]\nexclude=TestD\nclean_requirements_on_remove=true"
  When I execute "dnf" command "--installroot=/dockertesting -y -c /test/dnf.conf install TestE" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestE" with "success"
  When I execute "dnf" command "--installroot=/dockertesting -y -c /test/dnf.conf install TestD" with "fail"
  When I execute "bash" command "rpm -q --root=/dockertesting TestD" with "fail"
  When I execute "dnf" command "--installroot=/dockertesting -y install TestD" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestD" with "success"

Scenario: Reposdir option in dnf conf.file in host
  Given I use the repository "upgrade_1"
  When I create a file "/etc/dnf/dnf.conf" with content: "[main]\nreposdir=/var/www/html/repo/test-1-gpg"
  When I execute "dnf" command "-y install TestN" with "success"
  Then package "TestN-1.0.0-1" should be "installed"

Scenario: Reposdir option in dnf.conf file in installroot=dockertesting2
  Given I use the repository "test-1"
  When I create a file "/dockertesting2/etc/dnf/dnf.conf" with content: "[main]\nreposdir=/var/www/html/repo/upgrade_1-gpg"
  When I create a file "/dockertesting2/var/www/html/repo/upgrade_1-gpg/install.repo" with content: "[upgrade_1-gpg-file]\nname=upgrade_1-gpg-file\nbaseurl=http://127.0.0.1/repo/upgrade_1-gpg\nenabled=1\ngpgcheck=1\ngpgkey=file:///var/www/html/repo/upgrade_1-gpg/RPM-GPG-KEY-dtest2"
  When I execute "dnf" command "--installroot=/dockertesting2 -y install TestN" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting2 TestN" with "success"
  Then line from "stdout" should "start" with "TestN-1.0.0-4"

Scenario: Reposdir option in dnf.conf file with --config option in installroot=dockertesting2
  Given I use the repository "test-1"
  When I create a file "/dnf/dnf.conf" with content: "[main]\nreposdir=/var/www/html/repo/test-1-gpg"
  When I create a file "/dockertesting2/var/www/html/repo/test-1-gpg/test.repo" with content: "[test]\nname=test\nbaseurl=http://127.0.0.1/repo/test-1-gpg\nenabled=1\ngpgcheck=1\ngpgkey=file:///var/www/html/repo/test-1-gpg/RPM-GPG-KEY-dtest1"
  When I execute "dnf" command "--installroot=/dockertesting2 -c /dnf/dnf.conf -y install TestC" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting2 TestC" with "success"
  Then line from "stdout" should "start" with "TestC-1.0.0-1"
