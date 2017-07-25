Feature: DNF/Behave test (GPG key import in installroot)

Scenario: GPG key import after package install from host repository into installroot
 When _deprecated I execute "dnf" command "config-manager --add-repo http://127.0.0.1/repo/test-1-gpg/test-1-gpg-file.repo" with "success"
 When _deprecated I execute "dnf" command "repolist" with "success"
 Then _deprecated line from "stdout" should "start" with "test-1-gpg-file"
 When _deprecated I execute "bash" command "rpm --root=/dockertesting -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "fail"
 When _deprecated I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then _deprecated line from "stdout" should "not start" with "gpg-pubkey-2d2e7ca3-56c1e69d --> gpg(DNF Test1 (TESTER) <dnf@testteam.org>)"
 When _deprecated I execute "dnf" command "--installroot=/dockertesting -y --disablerepo=* --enablerepo=test-1-gpg-file install TestA" with "success"
 When _deprecated I execute "bash" command "rpm -q --root=/dockertesting TestA TestB" with "success"
 Then _deprecated line from "stdout" should "start" with "TestA-1.0.0-1."
 And _deprecated line from "stdout" should "start" with "TestB-1.0.0-1."
 When _deprecated I execute "bash" command "rpm --root=/dockertesting -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then _deprecated line from "stdout" should "start" with "gpg-pubkey-2d2e7ca3-56c1e69d --> gpg(DNF Test1 (TESTER) <dnf@testteam.org>)"
 When _deprecated I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then _deprecated line from "stdout" should "not start" with "gpg-pubkey-2d2e7ca3-56c1e69d --> gpg(DNF Test1 (TESTER) <dnf@testteam.org>)"
