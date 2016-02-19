Feature: DNF/Behave test (DNF config and config files in installroot)

Scenario: Create dnf.conf file and test if host is using /etc/dnf/dnf.conf.
  Given I use the repository "test-1"
  When I execute "dnf" command "install -y TestC" with "success"
  Then package "TestC" should be "installed"
  When I create a file "/etc/dnf/dnf.conf" with content: "[main]\nexclude=TestA"
  When I execute "dnf" command "install -y TestA" with "fail"
  Then package "TestA, TestB" should be "absent"

Scenario: Test removal of depemdency when clean_requirements_on_remove=false
  When I create a file "/etc/dnf/dnf.conf" with content: "[main]\nexclude=TestA\nclean_requirements_on_remove=false"
  When I execute "dnf" command "install -y --disableexclude=main TestA" with "success"
  Then package "TestA, TestB" should be "installed"
  When I execute "dnf" command "remove -y --disableexclude=all TestA" with "success"
  Then package "TestA" should be "removed"
  When I execute "dnf" command "remove -y TestB" with "success"
  Then package "TestB" should be "removed"

Scenario: Create dnf.conf file and test if host is taking option -c /dnf.conf file (absolute and relative path)
  When I create a file "/dnf.conf" with content: "[main]\nexclude=TestD\nclean_requirements_on_remove=true"
  When I execute "dnf" command "install -y -c /dnf.conf TestA" with "success"
  Then package "TestA, TestB" should be "installed"
  When I execute "dnf" command "install -y -c /dnf.conf TestD" with "fail"
  When I execute "dnf" command "install -y --config dnf.conf TestD" with "fail"
# TestA cannot be removed due to host exclude in dnf.conf
  When I execute "dnf" command "remove -y TestA" with "fail"
# TestB can be removed because TestA that is installed and require TestB was excluded
  When I execute "dnf" command "remove -y TestB" with "success"
  Then package "TestA, TestB" should be "removed"

Scenario: Test without dnf.conf in installroot (dnf.conf is not taken from host)
  When I execute "dnf" command "config-manager --installroot=/dockertesting --add-repo /etc/yum.repos.d/test-1.repo" with "success"
  Then the path "/dockertesting/etc/yum.repos.d/test-1.repo" should be "present"
  And the path "/dockertesting/etc/dnf/dnf.conf" should be "absent"
  When I execute "dnf" command "--installroot=/dockertesting -y install TestA" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestA" with "success"
  Then line from "stdout" should "start" with "TestA-1.0.0-1."

Scenario: Test with dnf.conf in installroot (dnf.conf is taken from installroot)
  When I create a file "/dockertesting/etc/dnf/dnf.conf" with content: "[main]\nexclude=TestE"
  Then the path "/dockertesting/etc/dnf/dnf.conf" should be "present"
  When I execute "dnf" command "--installroot=/dockertesting -y install TestE" with "fail"
  When I execute "bash" command "rpm -q --root=/dockertesting TestE" with "fail"

Scenario: Test with dnf.conf in installroot and --config (dnf.conf is taken from --config)
  When I execute "dnf" command "--installroot=/dockertesting -y -c /dnf.conf install TestE" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestE" with "success"
  When I execute "dnf" command "--installroot=/dockertesting -y -c /dnf.conf install TestD" with "fail"
  When I execute "bash" command "rpm -q --root=/dockertesting TestD" with "fail"
  When I execute "dnf" command "--installroot=/dockertesting -y install TestD" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestD" with "success"
