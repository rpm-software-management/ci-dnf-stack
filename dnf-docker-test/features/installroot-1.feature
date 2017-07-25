Feature: DNF/Behave test (installroot test)

Scenario: Install package from host repository into empty installroot
  Given _deprecated I use the repository "test-1"
# In installroot there is no repository therefore it is taken from host.
  When _deprecated I execute "dnf" command "install --installroot=/dockertesting --releasever=23 -y TestC" with "success"
  Then _deprecated the path "/dockertesting/etc/yum.repos.d/test-1.repo" should be "absent"
  Then _deprecated transaction changes are as follows
    | State        | Packages      |
    | absent       | TestC         |
  When _deprecated I execute "bash" command "rpm -q --root=/dockertesting TestC" with "success"
  Then _deprecated line from "stdout" should "start" with "TestC-1.0.0-1."
