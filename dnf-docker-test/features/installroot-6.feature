Feature: DNF/Behave test (installroot test)

Scenario: Install package into empty installroot without specifying releasever
  When I create a file "/etc/yum.repos.d/var.repo" with content: "[var]\nname=var\nbaseurl=http://127.0.0.1/repo/$releasever\nenabled=1\ngpgcheck=0"
  Then the path "/etc/yum.repos.d/var.repo" should be "present"
  When I execute "bash" command "mv /var/www/html/repo/test-1 /var/www/html/repo/$(rpm -q --provides $(rpm -q --whatprovides system-release) | grep -Po '(?<=system-release\()\d+(?=\))')" with "success"
  When I execute "dnf" command "install --installroot=/dockertesting -y TestE" with "success"

  Then transaction changes are as follows
    | State        | Packages      |
    | installed    | TestE-1.0.0-1 |
  When I execute "bash" command "rpm -q --root=/dockertesting TestE" with "success"
  Then line from "stdout" should "start" with "TestE-1.0.0-1."
