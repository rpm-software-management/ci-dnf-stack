Feature: DNF/Behave test test (Test if group are marked correctly - mandatory unavailable)

Scenario: Install TestB first with RPM, then install TestA with DNF and observe if the Recommended TestC is also installed
  Given I use the repository "test-1"
# Initial check
  When I execute "dnf" command "group list Testgroup" with "success"
  Then line from "stdout" should "not start" with "Installed Groups:"
  And line from "stdout" should "start" with "Available Groups:"
# Exclude of mandatory package
# When I execute "dnf" command "group install -y --exclude=TestA Testgroup" with "fail"
# Then I execute "dnf" command "group list Testgroup" with "success"
# And line from "stdout" should "not start" with "Installed Groups:"
# And line from "stdout" should "start" with "Available Groups:"
# Test with "--assumeno"
  When I execute "dnf" command "group install --assumeno Testgroup" with "fail"
  Then I execute "dnf" command "group list Testgroup" with "success"
  And line from "stdout" should "not start" with "Installed Groups:"
  And line from "stdout" should "start" with "Available Groups:"
  When I execute "dnf" command "group install -y --exclude=TestC Testgroup" with "success"
  Then transaction changes are as follows
  | State        | Packages      |
  | installed    | TestA, TestB  |
  And I execute "dnf" command "group list Testgroup" with "success"
  And line from "stdout" should "start" with "Installed Groups:"
  And line from "stdout" should "not start" with "Available Groups:"
  When I execute "dnf" command "group -y remove Testgroup" with "success"
  Then transaction changes are as follows
  | State        | Packages     |
  | removed      | TestA, TestB |
  And I execute "dnf" command "group list Testgroup" with "success"
  And line from "stdout" should "not start" with "Installed Groups:"
  And line from "stdout" should "start" with "Available Groups:"
