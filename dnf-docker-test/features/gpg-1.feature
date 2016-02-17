Feature: DNF/Behave test (Import GPG-key and test repolist)

Scenario: Add repository to host with gpgcheck=1 from repofile and test 'repolist' command
 Given I use the repository "test-1"
 When I execute "dnf" command "repolist" with "success"
 Then line from "stdout" should "not start" with "upgrade_1-gpg"
 And line from "stdout" should "start" with "test-1"
 When I execute "dnf" command "config-manager --add-repo http://127.0.0.1/repo/upgrade_1-gpg/upgrade_1-gpg-file.repo" with "success"
 When I execute "dnf" command "repolist" with "success"
 Then line from "stdout" should "start" with "upgrade_1-gpg-file"
 And line from "stdout" should "start" with "test-1"
# Test if correct repo is enabled and gpg-key import
 When I execute "dnf" command "-y --disablerepo=* --enablerepo=upgrade_1-gpg-file install TestN" with "success"
 Then package "TestN" should be "installed"
 When I execute "bash" command "rpm --root=/dockertesting -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "fail"
 When I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then line from "stdout" should "start" with "gpg-pubkey-705f3e8c-56c2e298 --> gpg(DNF Test2 (TESTER) <dnf@testteam.org>)"
