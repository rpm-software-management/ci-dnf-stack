Feature: DNF/Behave test (Import GPG-key and test repolist)

Scenario: Add repository to host with gpgcheck=1 from repofile and test 'repolist' command plus dnf.log test
 Given I use the repository "test-1"
 When I execute "dnf" command "repolist" with "success"
 Then line from "stdout" should "not start" with "upgrade_1-gpg"
 And line from "stdout" should "start" with "test-1"
 When I execute "dnf" command "config-manager --add-repo http://127.0.0.1/repo/upgrade_1-gpg/upgrade_1-gpg-file.repo" with "success"
 When I execute "dnf" command "repolist" with "success"
 Then line from "stdout" should "start" with "upgrade_1-gpg-file"
 And line from "stdout" should "start" with "test-1"
# It also test if dnf.log file is used from host if package installed in host
 When I execute "bash" command "rm -f /var/log/dnf.log" with "success"
 Then the path "/var/log/dnf.log" should be "absent"
 When I execute "bash" command "rm -f /dockertesting/var/log/dnf.log" with "success"
 Then the path "/dockertesting/var/log/dnf.log" should be "absent"
# Test if correct repo is enabled and gpg-key import
 When I execute "dnf" command "-y --disablerepo=* --enablerepo=upgrade_1-gpg-file install TestN" with "success"
 Then package "TestN" should be "installed"
 And the path "/dockertesting/var/log/dnf.log" should be "absent"
 And the path "/var/log/dnf.log" should be "present"
 When I execute "bash" command "rpm --root=/dockertesting -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "fail"
 When I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then line from "stdout" should "start" with "gpg-pubkey-705f3e8c-56c2e298 --> gpg(DNF Test2 (TESTER) <dnf@testteam.org>)"
