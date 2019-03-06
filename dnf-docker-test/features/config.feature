Feature: DNF/Behave test (DNF config and config files in installroot)

Scenario: Create dnf.conf file and test if host is using /etc/dnf/dnf.conf.
  Given _deprecated I use the repository "test-1"
  When _deprecated I execute "dnf" command "install -y TestC" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | installed    | TestC      |
  When _deprecated I create a file "/etc/dnf/dnf.conf" with content: "[main]\nexclude=TestA"
  When _deprecated I execute "dnf" command "install -y TestA" with "fail"
  Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | absent       | TestA, TestB  |
  # Cleaning traces from scenario - dnf.conf with only main section
  When _deprecated I execute "dnf" command "remove -y TestC" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | removed      | TestC      |
  When _deprecated I create a file "/etc/dnf/dnf.conf" with content: "[main]"

Scenario: Create dnf.conf file and test if host is taking option -c /test/dnf.conf file (absolute and relative path)
  Given _deprecated I use the repository "test-1"
  When _deprecated I create a file "/etc/dnf/dnf.conf" with content: "[main]\nexclude=TestA\nclean_requirements_on_remove=false"
  When _deprecated I create a file "/test/dnf.conf" with content: "[main]\nexclude=TestD\nclean_requirements_on_remove=true"
  When _deprecated I execute "dnf" command "install -y -c /test/dnf.conf TestA" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestB  |
  When _deprecated I execute "dnf" command "install -y -c /test/dnf.conf TestD" with "fail"
  When _deprecated I execute "dnf" command "install -y --config test/dnf.conf TestD" with "fail"
# TestA cannot be removed due to host exclude in dnf.conf
  When I save rpmdb
  And I successfully run "dnf remove -y TestA"
  Then rpmdb does not change

# TestB can be removed because excludes were disabled
  When _deprecated I execute "dnf" command "remove -y --disableexcludes=all TestB" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | removed      | TestA, TestB  |

Scenario: Test without dnf.conf in installroot (dnf.conf is not taken from host)
  Given _deprecated I use the repository "test-1"
  When _deprecated I create a file "/test/dnf.conf" with content: "[main]\nexclude=TestD\nclean_requirements_on_remove=true"
  When _deprecated I create a file "/etc/dnf/dnf.conf" with content: "[main]\nexclude=TestA\nclean_requirements_on_remove=true"
  When _deprecated I execute "dnf" command "config-manager --setopt=reposdir=/dockertesting/etc/yum.repos.d --add-repo /etc/yum.repos.d/test-1.repo" with "success"
  Then _deprecated the path "/dockertesting/etc/yum.repos.d/test-1.repo" should be "present"
  And _deprecated the path "/dockertesting/etc/dnf/dnf.conf" should be "absent"
  When _deprecated I execute "dnf" command "--installroot=/dockertesting -y install TestA" with "fail"
  When _deprecated I execute "bash" command "rpm -q --root=/dockertesting TestA" with "fail"
  When _deprecated I create a file "/etc/dnf/dnf.conf" with content: "[main]\nclean_requirements_on_remove=true"
  When _deprecated I execute "dnf" command "--installroot=/dockertesting -y install TestA" with "success"
  When _deprecated I execute "bash" command "rpm -q --root=/dockertesting TestA" with "success"
  Then _deprecated line from "stdout" should "start" with "TestA-1.0.0-1."

Scenario: Reposdir option in dnf conf.file in host
  Given _deprecated I use the repository "upgrade_1"
  When _deprecated I create a file "/etc/dnf/dnf.conf" with content: "[main]\nreposdir=/var/www/html/repo/test-1-gpg"
  When _deprecated I execute "dnf" command "-y install TestN" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages       |
   | installed    | TestN-1.0.0-1  |
