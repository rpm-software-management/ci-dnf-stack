Feature: DNF/Behave test (test repolist with host and installroot)

Scenario: Add repository to installroot with gpgcheck=1 from repofile and control 'repolist' command
 Given _deprecated I use the repository "upgrade_1"
# Success and show host repository cached into installroot
 When _deprecated I execute "dnf" command "--installroot=/dockertesting repolist" with "success"
 Then _deprecated line from "stdout" should "start" with "upgrade_1"
 And _deprecated line from "stdout" should "not start" with "test-1-gpg-file"
 When _deprecated I execute "dnf" command "--setopt=reposdir=/dockertesting/etc/yum.repos.d config-manager --add-repo http://127.0.0.1/repo/test-1-gpg/test-1-gpg-file.repo" with "success"
 When _deprecated I execute "dnf" command "--installroot=/dockertesting repolist" with "success"
 Then _deprecated line from "stdout" should "start" with "test-1-gpg-file"
 And _deprecated line from "stdout" should "not start" with "upgrade_1"
