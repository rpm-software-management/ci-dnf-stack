Feature: DNF/Behave test (GPG key handing in installroot)

Scenario: Install signed package with signed dependecy with key from host from repository with gpgcheck=1
# Install package and import Test2-gpg-key to host
 When _deprecated I execute "dnf" command "config-manager --add-repo http://127.0.0.1/repo/upgrade_1-gpg/upgrade_1-gpg-file.repo" with "success"
 When _deprecated I execute "dnf" command "-y install TestN" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | installed    | TestN-1.0.0-4 |
 When _deprecated I execute "bash" command "rpm --root=/dockertesting -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "fail"
 When _deprecated I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then _deprecated line from "stdout" should "start" with "gpg-pubkey-705f3e8c-56c2e298 --> gpg(DNF Test2 (TESTER) <dnf@testteam.org>)"
# Install package and import Test1-gpg-key to installroot
 When _deprecated I execute "dnf" command "--setopt=reposdir=/dockertesting/etc/yum.repos.d config-manager --add-repo http://127.0.0.1/repo/test-1-gpg/test-1-gpg-file.repo" with "success"
 When _deprecated I execute "dnf" command "--installroot=/dockertesting -y install TestA" with "success"
 When _deprecated I execute "bash" command "rpm -q --root=/dockertesting TestA TestB" with "success"
 Then _deprecated line from "stdout" should "start" with "TestA-1.0.0-1."
 And _deprecated line from "stdout" should "start" with "TestB-1.0.0-1."
 When _deprecated I execute "bash" command "rpm --root=/dockertesting -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then _deprecated line from "stdout" should "start" with "gpg-pubkey-2d2e7ca3-56c1e69d --> gpg(DNF Test1 (TESTER) <dnf@testteam.org>)"
 When _deprecated I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then _deprecated line from "stdout" should "not start" with "gpg-pubkey-2d2e7ca3-56c1e69d --> gpg(DNF Test1 (TESTER) <dnf@testteam.org>)"
# Install package into installroot that requires gpg-key from host (fail)
 When _deprecated I execute "dnf" command "--installroot=/dockertesting -y install TestF" with "fail"
 When _deprecated I execute "bash" command "rpm -q --root=/dockertesting TestF TestG TestH" with "fail"
 Then _deprecated line from "stdout" should "not start" with "TestF"
 And _deprecated line from "stdout" should "not start" with "TestG"
 And _deprecated line from "stdout" should "not start" with "TestH"
