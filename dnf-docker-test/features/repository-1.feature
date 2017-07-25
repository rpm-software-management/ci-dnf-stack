Feature: Handling local base url in repository in new installroot dockertesting2

Scenario: Handling local base url in repository in new installroot dockertesting2
  Given _deprecated I use the repository "upgrade_1"
  When _deprecated I create a file "/dockertesting2/etc/yum.repos.d/var.repo" with content: "[var]\nname=var\nbaseurl=file:///var/www/html/repo/test-1\nenabled=1\ngpgcheck=0"
  Then _deprecated the path "/dockertesting2/etc/yum.repos.d/var.repo" should be "present"
  When _deprecated I execute "bash" command "rpm -q --root=/dockertesting2 TestC" with "fail"
  When _deprecated I execute "dnf" command "install --installroot=/dockertesting2 --releasever=23 -y TestC" with "success"
  When _deprecated I execute "bash" command "rpm -q --root=/dockertesting2 TestC" with "success"
  Then _deprecated line from "stdout" should "start" with "TestC-1.0.0-1."
