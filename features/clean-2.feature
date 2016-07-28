Feature: DNF/Behave test (clean - installroot)

Scenario: Ensure that metadata are unavailable after "dnf --installroot=path clean all"
  Given I use the repository "test-1"
  When I create a file "/dockertesting1/etc/yum.repos.d/test-1.repo" with content: "[test-1]\nname=test-1\nbaseurl=file:///var/www/html/repo/test-1\nenabled=1\ngpgcheck=0\nskip_if_unavailable=False"
  When I execute "dnf" command "--installroot=/dockertesting1 makecache" with "success"
  Then I execute "dnf" command "--installroot=/dockertesting1 -y -C install TestB" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting1 TestB" with "success"
  When I execute "dnf" command "--installroot=/dockertesting1 clean all" with "success"
  Then I execute "dnf" command "--installroot=/dockertesting1 -y -C install TestC" with "fail"
  When I execute "bash" command "rpm -q --root=/dockertesting1 TestC" with "fail"
