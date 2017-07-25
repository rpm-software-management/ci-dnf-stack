Feature: DNF/Behave test test (Test if group are marked correctly - mandatory unavailable)

Scenario: Install TestB first with RPM, then install TestA with DNF and observe if the Recommended TestC is also installed
  Given _deprecated I use the repository "test-1"
# Initial check
  When _deprecated I execute "dnf" command "group list Testgroup" with "success"
  Then _deprecated line from "stdout" should "not start" with "Installed Groups:"
  And _deprecated line from "stdout" should "start" with "Available Groups:"
# Exclude of mandatory package
# When _deprecated I execute "dnf" command "group install -y --exclude=TestA Testgroup" with "fail"
# Then _deprecated I execute "dnf" command "group list Testgroup" with "success"
# And _deprecated line from "stdout" should "not start" with "Installed Groups:"
# And _deprecated line from "stdout" should "start" with "Available Groups:"
# Test with "--assumeno"
  When _deprecated I execute "dnf" command "group install --assumeno Testgroup" with "fail"
  Then _deprecated I execute "dnf" command "group list Testgroup" with "success"
  And _deprecated line from "stdout" should "not start" with "Installed Groups:"
  And _deprecated line from "stdout" should "start" with "Available Groups:"
  When _deprecated I execute "dnf" command "group install -y --exclude=TestC Testgroup" with "success"
  Then _deprecated transaction changes are as follows
  | State        | Packages      |
  | installed    | TestA, TestB  |
  And _deprecated I execute "dnf" command "group list Testgroup" with "success"
  And _deprecated line from "stdout" should "start" with "Installed Groups:"
  And _deprecated line from "stdout" should "not start" with "Available Groups:"
  When _deprecated I execute "dnf" command "group -y remove Testgroup" with "success"
  Then _deprecated transaction changes are as follows
  | State        | Packages     |
  | removed      | TestA, TestB |
  And _deprecated I execute "dnf" command "group list Testgroup" with "success"
  And _deprecated line from "stdout" should "not start" with "Installed Groups:"
  And _deprecated line from "stdout" should "start" with "Available Groups:"
