Feature: Handling local base url in repository in new installroot dockertesting3

Scenario: Handling local base url in repository in new installroot dockertesting3
  Given _deprecated I use the repository "upgrade_1"
  When _deprecated I create a file "/dockertesting3/etc/yum.repos.d/test-1.repo" with content: "[test-1]\nname=test-1\nbaseurl=http://127.0.0.1/repo/test-1\nenabled=1\ngpgcheck=0"
  When _deprecated I execute "bash" command "rpm -q --root=/dockertesting3 TestC" with "fail"
  When _deprecated I execute "dnf" command "install --installroot=/dockertesting3 --releasever=23 -y TestC" with "success"
  When _deprecated I execute "bash" command "rpm -q --root=/dockertesting3 TestC" with "success"
  Then _deprecated line from "stdout" should "start" with "TestC-1.0.0-1."
