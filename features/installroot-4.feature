Feature: DNF/Behave test (test repolist with host and installroot)

Scenario: Add repository to installroot with gpgcheck=1 from repofile and control 'repolist' command
 Given I use the repository "upgrade_1"
# Success and show host repository cached into installroot
 When I execute "dnf" command "--installroot=/dockertesting repolist" with "success"
 Then line from "stdout" should "start" with "upgrade_1"
 And line from "stdout" should "not start" with "test-1-gpg-file"
 When I execute "dnf" command "--setopt=reposdir=/dockertesting/etc/yum.repos.d config-manager --add-repo http://127.0.0.1/repo/test-1-gpg/test-1-gpg-file.repo" with "success"
 When I execute "dnf" command "--installroot=/dockertesting repolist" with "success"
 Then line from "stdout" should "start" with "test-1-gpg-file"
 And line from "stdout" should "not start" with "upgrade_1"
