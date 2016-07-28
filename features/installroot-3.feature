Feature: DNF/Behave test (installroot test)

Scenario: Remove package from installroot
  When I execute "dnf" command "--setopt=reposdir=/dockertesting/etc/yum.repos.d config-manager --add-repo http://127.0.0.1/repo/test-1" with "success"
  When I execute "dnf" command "--installroot=/dockertesting --setopt=gpgcheck=0 config-manager --save 127.0.0.1_repo_test-1" with "success"
  When I execute "dnf" command "-y --installroot /dockertesting install TestA TestC" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestA TestB TestC" with "success"
  Then line from "stdout" should "start" with "TestA-1.0.0-1."
  And line from "stdout" should "start" with "TestB-1.0.0-1."
  And line from "stdout" should "start" with "TestC-1.0.0-1."
  When I execute "dnf" command "remove --installroot=/dockertesting -y TestC" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestC" with "fail"

