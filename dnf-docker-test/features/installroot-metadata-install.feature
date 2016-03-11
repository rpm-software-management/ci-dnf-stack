Feature: DNF/Behave test (installroot test)

Scenario: Move repository "test-1" into installroot
  Given I use the repository "test-1"
# In installroot there is no repository therefore the install fails.
  When I execute "dnf" command "install --installroot=/dockertesting --releasever=23 -y TestC" with "fail"
  Then the path "/dockertesting/etc/yum.repos.d/test-1.repo" should be "absent"
  And line from "stderr" should "start" with "Error: There are no enabled repos."
# It installs repo test-1 from host to installroot.
  When I execute "dnf" command "config-manager --installroot=/dockertesting --add-repo /etc/yum.repos.d/test-1.repo" with "success"
  Then the path "/dockertesting/etc/yum.repos.d/test-1.repo" should be "present"

Scenario: Install package from installroot repository into installroot, test metadata handling in installroot
  Given I use the repository "upgrade_1"
# Install first package from installroot repo into installroot and make cache for metadata in installroot.
  When I execute "dnf" command "install --installroot=/dockertesting --releasever=23 -y TestC" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestC" with "success"
  Then line from "stdout" should "start" with "TestC-1.0.0-1."
  When I execute "bash" command "rpm -q TestC" with "fail"
# Install package from host repo into host and make host cache for metadata in host
  When I execute "dnf" command "install -y TestB" with "success"
  Then transaction changes are as follows
   | State        | Packages       |
   | installed    | TestB-1.0.0-2  |
# Delete installroot cache and commands for installroot with -C should fail
  When I execute "bash" command "rm -rf /dockertesting/var/cache/dnf/*" with "success"
  When I execute "dnf" command "install --installroot=/dockertesting --releasever=23  -y -C TestB" with "fail"
  When I execute "bash" command "rpm -q --root=/dockertesting TestB" with "fail"
# If makecache for installroot it downloads correct metadata for installroot and install package with -C into installroot
  When I execute "dnf" command "--installroot=/dockertesting --releasever=23  makecache" with "success"
  When I execute "dnf" command "install --installroot=/dockertesting --releasever=23  -y -C TestB" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestB" with "success"
  Then line from "stdout" should "start" with "TestB-1.0.0-1."
  When I execute "dnf" command "remove --installroot=/dockertesting --releasever=23 -y TestB" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestB" with "fail"
  When I execute "bash" command "rpm -q TestB" with "success"
  Then line from "stdout" should "start" with "TestB-1.0.0-2."

Scenario: Add repository to host with gpgcheck=1 from repofile and control 'repolist' command plus dnf.log test
 When I execute "dnf" command "repolist" with "success"
 Then line from "stdout" should "not start" with "upgrade_1-gpg*"
 When I execute "dnf" command "config-manager --add-repo http://127.0.0.1/repo/upgrade_1-gpg/upgrade_1-gpg-file.repo" with "success"
 When I execute "dnf" command "repolist upgrade_1-g*" with "success"
 Then line from "stdout" should "start" with "upgrade_1-gpg-file"
# It also test if dnf.log file is used from host if package installed in host
 When I execute "bash" command "rm -f /var/log/dnf.log" with "success"
 Then the path "/var/log/dnf.log" should be "absent"
 When I execute "bash" command "rm -f /dockertesting/var/log/dnf.log" with "success"
 Then the path "/dockertesting/var/log/dnf.log" should be "absent"
 When I execute "dnf" command "-y --disablerepo=* --enablerepo=upgrade_1-gpg-file install TestN" with "success"
 Then transaction changes are as follows
   | State        | Packages   |
   | installed    | TestN      |
 And the path "/dockertesting/var/log/dnf.log" should be "absent"
 And the path "/var/log/dnf.log" should be "present"
 When I execute "bash" command "rpm --root=/dockertesting -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "fail"
 When I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then line from "stdout" should "start" with "gpg-pubkey-705f3e8c-56c2e298 --> gpg(DNF Test2 (TESTER) <dnf@testteam.org>)"

Scenario: Add repository to installroot with gpgcheck=1 from repofile and control 'repolist' command
 When I execute "dnf" command "--installroot=/dockertesting repolist" with "success"
 Then line from "stdout" should "not start" with "test-1-gpg-file"
 When I execute "dnf" command "--installroot=/dockertesting config-manager --add-repo http://127.0.0.1/repo/test-1-gpg/test-1-gpg-file.repo" with "success"
 When I execute "dnf" command "--installroot=/dockertesting repolist test-1-g*" with "success"
 Then line from "stdout" should "start" with "test-1-gpg-file"

Scenario: GPG key import after package install plus dnf.log test in installroot
 When I execute "bash" command "rpm --root=/dockertesting -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "fail"
 When I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then line from "stdout" should "not start" with "gpg-pubkey-2d2e7ca3-56c1e69d --> gpg(DNF Test1 (TESTER) <dnf@testteam.org>)"
# It also test if dnf.log file is used from installroot if package installed in installroot
 When I execute "bash" command "rm -f /var/log/dnf.log" with "success"
 Then the path "/var/log/dnf.log" should be "absent"
 When I execute "bash" command "rm -f /dockertesting/var/log/dnf.log" with "success"
 Then the path "/dockertesting/var/log/dnf.log" should be "absent"
 When I execute "dnf" command "--installroot=/dockertesting -y --disablerepo=* --enablerepo=test-1-gpg-file install TestA" with "success"
 Then the path "/dockertesting/var/log/dnf.log" should be "present"
 When I execute "bash" command "rpm -q --root=/dockertesting TestA TestB" with "success"
 Then line from "stdout" should "start" with "TestA-1.0.0-1."
 And line from "stdout" should "start" with "TestB-1.0.0-1."
 When I execute "bash" command "rpm --root=/dockertesting -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then line from "stdout" should "start" with "gpg-pubkey-2d2e7ca3-56c1e69d --> gpg(DNF Test1 (TESTER) <dnf@testteam.org>)"
 When I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then line from "stdout" should "not start" with "gpg-pubkey-2d2e7ca3-56c1e69d --> gpg(DNF Test1 (TESTER) <dnf@testteam.org>)"

Scenario: Install signed package with signed dependecy with key from host from repository with gpgcheck=1
 When I execute "dnf" command "--installroot=/dockertesting -y --disablerepo=* --enablerepo=test-1-gpg-file install TestF" with "fail"
 When I execute "bash" command "rpm -q --root=/dockertesting TestF TestG TestH" with "fail"
 Then line from "stdout" should "not start" with "TestF"
 And line from "stdout" should "not start" with "TestG"
 And line from "stdout" should "not start" with "TestH"

Scenario: Remove package from installroot
  When I execute "dnf" command "remove --installroot=/dockertesting --releasever=23 -y TestC" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting TestC" with "fail"

Scenario: Tracking information are stored in host persist-dir if package is installed in host
  Given I use the repository "upgrade_1"
  When I execute "bash" command "rm -rf /var/lib/dnf" with "success"
  Then the path "/var/lib/dnf/" should be "absent"
  When I execute "dnf" command "-y install TestG" with "success"
  Then transaction changes are as follows
   | State        | Packages   |
   | installed  | TestG  |
  And the path "/var/lib/dnf/*" should be "present"

Scenario: Tracking information are stored in installroot persist-dir if package is installed in installroot
  When I execute "bash" command "rm -rf /dockertesting/var/lib/dnf" with "success"
  Then the path "/dockertesting/var/lib/dnf/" should be "absent"
  When I execute "dnf" command "--installroot=/dockertesting -y --disablerepo=* --enablerepo=test-1 install TestH" with "success"
  Then the path "/dockertesting/var/lib/dnf/*" should be "present"
  When I execute "bash" command "rpm -q --root=/dockertesting TestH" with "success"

Scenario: Handling local base url in repository in new installroot dockertesting2
  Given I use the repository "upgrade_1"
  When I create a file "/dockertesting2/etc/yum.repos.d/var.repo" with content: "[var]\nname=var\nbaseurl=file:///var/www/html/repo/test-1\nenabled=1\ngpgcheck=0"
  Then the path "/dockertesting2/etc/yum.repos.d/var.repo" should be "present"
  When I execute "bash" command "rpm -q --root=/dockertesting2 TestC" with "fail"
  When I execute "dnf" command "install --installroot=/dockertesting2 --releasever=23 -y TestC" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting2 TestC" with "success"
  Then line from "stdout" should "start" with "TestC-1.0.0-1."

Scenario: Handling local base url in repository in new installroot dockertesting3
  Given I use the repository "upgrade_1"
  When I execute "dnf" command "config-manager --installroot=/dockertesting3 --add-repo /var/www/html/repo/test-1" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting3 TestC" with "fail"
  When I execute "dnf" command "install --installroot=/dockertesting3 --releasever=23 -y TestC" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting3 TestC" with "success"
  Then line from "stdout" should "start" with "TestC-1.0.0-1."
