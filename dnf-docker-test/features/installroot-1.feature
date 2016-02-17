Feature: DNF/Behave test (installroot test)

Scenario: Install package from host repository into empty installroot
  Given I use the repository "test-1"
# In installroot there is no repository therefore it is taken from host.
  When I execute "dnf" command "install --installroot=/dockertesting --releasever=23 -y TestC" with "success"
  Then the file "/dockertesting/etc/yum.repos.d/test-1.repo" should be "absent"
  And package "TestC" should be "absent"
  When I execute "bash" command "rpm -q --root=/dockertesting TestC" with "success"
  Then line from "stdout" should "start" with "TestC-1.0.0-1."
