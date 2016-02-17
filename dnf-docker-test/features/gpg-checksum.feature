Feature: DNF/Behave test (gpg, check-sum)

Scenario: Add repository with gpgcheck=1 from repofile and control 'repolist' command
 Given I use the repository "test-1"
 When I execute "dnf" command "repolist" with "success"
 Then line from "stdout" should "start" with "test-1 "
 And line from "stdout" should "not start" with "test-1-gpg-file"
 When I execute "dnf" command "config-manager --add-repo http://127.0.0.1/repo/test-1-gpg/test-1-gpg-file.repo" with "success"
 When I execute "dnf" command "repolist test-1-g*" with "success"
 Then line from "stdout" should "not start" with "test-1 "
 And line from "stdout" should "start" with "test-1-gpg-file"

Scenario: GPG key import after package install
 When I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then line from "stdout" should "not start" with "gpg-pubkey-2d2e7ca3-56c1e69d --> gpg(DNF Test1 (TESTER) <dnf@testteam.org>)"
 When I execute "dnf" command "-y --disablerepo=test-1 install TestA" with "success"
 Then package "TestA, TestB" should be "installed"
 When I execute "bash" command "rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'" with "success"
 Then line from "stdout" should "start" with "gpg-pubkey-2d2e7ca3-56c1e69d --> gpg(DNF Test1 (TESTER) <dnf@testteam.org>)"
# Cleaning artifacts from test
 When I execute "dnf" command "-y remove TestA" with "success"
 Then package "TestA, TestB" should be "removed"

Scenario: Install signed package with unsigned dependecy from repository with gpgcheck=1
 When I execute "dnf" command "-y --disablerepo=test-1 install TestD" with "fail"
 Then package "TestD, TestE" should be "absent"

Scenario: Install signed package with signed dependece with different key from repository with gpgcheck=1
 When I execute "dnf" command "-y --disablerepo=test-1 install TestF" with "fail"
 Then package "TestF, TestG, TestH" should be "absent"

Scenario: Install package with incorrect checksum from repository with gpgcheck=1
 Then the file "/var/cache/dnf/expired_repos.json" should contain "[]"
 When I execute "dnf" command "-y --disablerepo=test-1 install TestJ" with "fail"
 Then package "TestJ" should be "absent"
 Then the file "/var/cache/dnf/expired_repos.json" should contain "["test-1-gpg-file"]"
 When I execute "dnf" command "makecache" with "success"
 Then the file "/var/cache/dnf/expired_repos.json" should contain "[]"

Scenario: Add repository with gpgcheck=0 and install package with unknown key and signed and unsigned packages
 Given I use the repository "test-1-gpg"
 When I execute "dnf" command "-y install TestF" with "success"
 Then package "TestF, TestG, TestH" should be "installed"
 When I execute "dnf" command "-y install TestD" with "success"
 Then package "TestD, TestE" should be "installed"
# Cleaning artifacts from test
 When I execute "dnf" command "-y remove TestF TestD" with "success"
 Then package "TestD, TestE, TestF, TestG, TestH" should be "removed"

#It is brocken - activate after fix in dnf - if gpgcheck=0 dnf doesn't controle checksum (https://bugzilla.redhat.com/show_bug.cgi?id=1314405)
#Scenario: Install package with incorrect checksum from repository with gpgcheck=0
# Given I use the repository "test-1-gpg"
# Then the file "/var/cache/dnf/expired_repos.json" should contain "[]"
# When I execute "dnf" command "-y install TestJ" with "fail"
# Then package "TestJ" should be "absent"
# Then the file "/var/cache/dnf/expired_repos.json" should contain "["test-1-gpg"]"
