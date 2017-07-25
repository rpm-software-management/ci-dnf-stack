Feature: DNF/Behave test (Import GPG-key and test repolist)

Scenario: Add repository to host with gpgcheck=1 from repofile and test 'repolist' command plus dnf.log test
 Given _deprecated I use the repository "test-1"
 When _deprecated I execute "dnf" command "repolist" with "success"
 Then _deprecated line from "stdout" should "not start" with "upgrade_1-gpg"
 And _deprecated line from "stdout" should "start" with "test-1"
 When _deprecated I execute "dnf" command "config-manager --add-repo http://127.0.0.1/repo/upgrade_1-gpg/upgrade_1-gpg-file.repo" with "success"
 When _deprecated I execute "dnf" command "repolist" with "success"
 Then _deprecated line from "stdout" should "start" with "upgrade_1-gpg-file"
 And _deprecated line from "stdout" should "start" with "test-1"
# It also test if dnf.log file is used from host if package installed in host
 When _deprecated I execute "bash" command "rm -f /var/log/dnf.log" with "success"
 Then _deprecated the path "/var/log/dnf.log" should be "absent"
 When _deprecated I execute "bash" command "rm -f /dockertesting/var/log/dnf.log" with "success"
 Then _deprecated the path "/dockertesting/var/log/dnf.log" should be "absent"
# Test if correct repo is enabled and gpg-key import
 When _deprecated I execute "dnf" command "-y --disablerepo=* --enablerepo=upgrade_1-gpg-file install TestN" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | installed    | TestN-1.0.0-4 |
 And _deprecated the path "/dockertesting/var/log/dnf.log" should be "absent"
 And _deprecated the path "/var/log/dnf.log" should be "present"
 When _deprecated I execute "bash" command "rpm --root=/dockertesting -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "fail"
 When _deprecated I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then _deprecated line from "stdout" should "start" with "gpg-pubkey-705f3e8c-56c2e298 --> gpg(DNF Test2 (TESTER) <dnf@testteam.org>)"
