Feature: DNF/Behave test (GPG key import in installroot)

Scenario: GPG key import after package install from installroot repository into installroot
 When _deprecated I execute "dnf" command "--setopt=reposdir=/dockertesting/etc/yum.repos.d config-manager --add-repo http://127.0.0.1/repo/test-1-gpg/test-1-gpg-file.repo" with "success"
 When _deprecated I execute "bash" command "rpm --root=/dockertesting -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "fail"
 When _deprecated I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then _deprecated line from "stdout" should "not start" with "gpg-pubkey-2d2e7ca3-56c1e69d --> gpg(DNF Test1 (TESTER) <dnf@testteam.org>)"
# It also test if dnf.log file is used from installroot if package installed in installroot
 When _deprecated I execute "bash" command "rm -f /var/log/dnf.log" with "success"
 Then _deprecated the path "/var/log/dnf.log" should be "absent"
 When _deprecated I execute "bash" command "rm -f /dockertesting/var/log/dnf.log" with "success"
 Then _deprecated the path "/dockertesting/var/log/dnf.log" should be "absent"
 When _deprecated I execute "dnf" command "--installroot=/dockertesting -y --disablerepo=* --enablerepo=test-1-gpg-file install TestA" with "success"
 Then _deprecated the path "/dockertesting/var/log/dnf.log" should be "present"
 When _deprecated I execute "bash" command "rpm -q --root=/dockertesting TestA TestB" with "success"
 Then _deprecated line from "stdout" should "start" with "TestA-1.0.0-1."
 And _deprecated line from "stdout" should "start" with "TestB-1.0.0-1."
 When _deprecated I execute "bash" command "rpm --root=/dockertesting -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then _deprecated line from "stdout" should "start" with "gpg-pubkey-2d2e7ca3-56c1e69d --> gpg(DNF Test1 (TESTER) <dnf@testteam.org>)"
 When _deprecated I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then _deprecated line from "stdout" should "not start" with "gpg-pubkey-2d2e7ca3-56c1e69d --> gpg(DNF Test1 (TESTER) <dnf@testteam.org>)"
