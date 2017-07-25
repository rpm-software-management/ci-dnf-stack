Feature: DNF/Behave test (installroot test)

Scenario: Remove package from installroot
  When _deprecated I execute "dnf" command "--setopt=reposdir=/dockertesting/etc/yum.repos.d config-manager --add-repo http://127.0.0.1/repo/test-1" with "success"
  When _deprecated I execute "dnf" command "--installroot=/dockertesting --setopt=gpgcheck=0 config-manager --save 127.0.0.1_repo_test-1" with "success"
  When _deprecated I execute "dnf" command "-y --installroot /dockertesting install TestA TestC" with "success"
  When _deprecated I execute "bash" command "rpm -q --root=/dockertesting TestA TestB TestC" with "success"
  Then _deprecated line from "stdout" should "start" with "TestA-1.0.0-1."
  And _deprecated line from "stdout" should "start" with "TestB-1.0.0-1."
  And _deprecated line from "stdout" should "start" with "TestC-1.0.0-1."
  When _deprecated I execute "dnf" command "remove --installroot=/dockertesting -y TestC" with "success"
  When _deprecated I execute "bash" command "rpm -q --root=/dockertesting TestC" with "fail"

