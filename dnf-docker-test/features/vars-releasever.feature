Feature: DNF/Behave test (vars and releasever tests)

Scenario: Test vars from host
  When I create a file "/etc/yum.repos.d/var.repo" with content: "[var]\nname=var\nbaseurl=http://127.0.0.1/repo/$repo\nenabled=1\ngpgcheck=0"
  Then the path "/etc/yum.repos.d/var.repo" should be "present"
  When I execute "dnf" command "install -y TestC" with "fail"
  Then package "TestC" should be "absent"
  When I create a file "/etc/dnf/vars/repo" with content: "test-1"
  Then the path "/etc/dnf/vars/repo" should be "present"
  When I execute "dnf" command "install -y TestC" with "success"
  Then package "TestC" should be "installed"

Scenario: Test vars taken from installroot
  When I create a file "/dockertesting/etc/yum.repos.d/var.repo" with content: "[var]\nname=var\nbaseurl=http://127.0.0.1/repo/$repo\nenabled=1\ngpgcheck=0"
  Then the path "/dockertesting/etc/yum.repos.d/var.repo" should be "present"
  When I execute "dnf" command "--installroot=/dockertesting -y install TestB" with "fail"
  When I execute "bash" command "rpm -q --root=/dockertesting TestB" with "fail"
  When I create a file "/dockertesting/etc/dnf/vars/repo" with content: "upgrade_1"
  Then the path "/dockertesting/etc/dnf/vars/repo" should be "present"
  When I execute "dnf" command "--installroot=/dockertesting -y install TestB" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestB" with "success"
  Then line from "stdout" should "start" with "TestB-1.0.0-2."

 Scenario: Test host releasever
  When I create a file "/etc/yum.repos.d/var.repo" with content: "[var]\nname=var\nbaseurl=http://127.0.0.1/repo/$releasever\nenabled=1\ngpgcheck=0"
  Then the path "/etc/yum.repos.d/var.repo" should be "present"
  When I execute "bash" command "mv /var/www/html/repo/test-1 /var/www/html/repo/23" with "success"
  When I execute "bash" command "mv /var/www/html/repo/upgrade_1 /var/www/html/repo/22" with "success"
  When I execute "dnf" command "install -y TestE" with "success"
  Then package "TestE-1.0.0-1" should be "installed"
  When I execute "dnf" command "-y --releasever=22 install TestG" with "success"
  Then package "TestG-1.0.0-2" should be "installed"

Scenario: Test vars taken from installroot
  When I create a file "/dockertesting/etc/yum.repos.d/var.repo" with content: "[var]\nname=var\nbaseurl=http://127.0.0.1/repo/$releasever\nenabled=1\ngpgcheck=0"
  Then the path "/dockertesting/etc/yum.repos.d/var.repo" should be "present"
  When I execute "dnf" command "--installroot=/dockertesting -y install TestE" with "fail"
  When I execute "bash" command "rpm -q --root=/dockertesting TestE" with "fail"
  When I execute "dnf" command "--installroot=/dockertesting -y --releasever=23 install TestE" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestE" with "success"
  Then line from "stdout" should "start" with "TestE-1.0.0-1."
