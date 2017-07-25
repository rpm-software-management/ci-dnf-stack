Feature: DNF/Behave test (test upgrade in installroot)

Scenario: test upgrade in installroot
  Given _deprecated I use the repository "test-1"
  When _deprecated I execute "dnf" command "install -y TestA" with "success"
  Then _deprecated the path "/dockertesting/etc/yum.repos.d/test-1.repo" should be "absent"
  Then _deprecated transaction changes are as follows
    | State           | Packages                       |
    | installed       | TestA-1.0.0-1, TestB-1.0.0-1   |
  When _deprecated I execute "dnf" command "install --installroot=/dockertesting --releasever=23 -y TestA" with "success"
  Then _deprecated I execute "bash" command "rpm -q --root=/dockertesting TestA TestB" with "success"
  And _deprecated line from "stdout" should "start" with "TestA-1.0.0-1."
  And _deprecated line from "stdout" should "start" with "TestB-1.0.0-1."
  Given _deprecated I use the repository "upgrade_1"
  When _deprecated I execute "dnf" command "upgrade --installroot=/dockertesting -y" with "success"
  Then _deprecated I execute "bash" command "rpm -q --root=/dockertesting TestA TestB" with "success"
  And _deprecated line from "stdout" should "start" with "TestA-1.0.0-2."
  And _deprecated line from "stdout" should "start" with "TestB-1.0.0-2."
  And _deprecated transaction changes are as follows
    | State         | Packages                       |
    | present       | TestA-1.0.0-1, TestB-1.0.0-1   |
