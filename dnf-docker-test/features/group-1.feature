Feature: DNF/Behave test test (Test if group are marked correctly - transaction fail)

Scenario: Install TestB first with RPM, then install TestA with DNF and observe if the Recommended TestC is also installed
  Given _deprecated I use the repository "test-1"
# Initial check
  When _deprecated I execute "dnf" command "group list Testgroup" with "success"
  Then _deprecated line from "stdout" should "not start" with "Installed Groups:"
  And _deprecated line from "stdout" should "start" with "Available Groups:"
# Exclude of dependency of mandatory package
# When _deprecated I execute "dnf" command "group install -y --exclude=TestB Testgroup" with "fail"
# Then _deprecated I execute "dnf" command "group list Testgroup" with "success"
# And _deprecated line from "stdout" should "not start" with "Installed Groups:"
# And _deprecated line from "stdout" should "start" with "Available Groups:"
  When _deprecated I execute "dnf" command "group install -y --exclude=TestC Testgroup" with "success"
  Then _deprecated transaction changes are as follows
  | State        | Packages                   |
  | installed    | TestA, TestB |
  And _deprecated I execute "dnf" command "group list Testgroup" with "success"
  And _deprecated line from "stdout" should "start" with "Installed Groups:"
  And _deprecated line from "stdout" should "not start" with "Available Groups:"
  When _deprecated I execute "dnf" command "-y group remove Testgroup" with "success"
  Then _deprecated transaction changes are as follows
  | State        | Packages            |
  | removed      | TestA, TestB |
  And _deprecated I execute "dnf" command "group list Testgroup" with "success"
  And _deprecated line from "stdout" should "not start" with "Installed Groups:"
  And _deprecated line from "stdout" should "start" with "Available Groups:"
