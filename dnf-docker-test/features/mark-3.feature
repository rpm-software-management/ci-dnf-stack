Feature: DNF/Behave test (dnf group mark command)

Scenario: Mark group as installed and unmark group as installed
 Given _deprecated I use the repository "test-1"
 When _deprecated I execute "dnf" command "group list Testgroup" with "success"
 Then _deprecated line from "stdout" should "not start" with "Installed Groups:"
 And _deprecated line from "stdout" should "start" with "Available Groups:"
 When _deprecated I execute "dnf" command "group mark install Testgroup" with "success"
 # TestA-mandatory, TestC-defaults, TestD-optional
 Then _deprecated transaction changes are as follows
   | State       | Packages             |
   | absent      | TestA, TestC, TestD  |
 And _deprecated I execute "dnf" command "group list Testgroup" with "success"
 And _deprecated line from "stdout" should "start" with "Installed Groups:"
 And _deprecated line from "stdout" should "not start" with "Available Groups:"
 When _deprecated I execute "dnf" command "group mark remove Testgroup" with "success"
 Then _deprecated transaction changes are as follows
   | State       | Packages             |
   | absent      | TestA, TestC, TestD  |
 And _deprecated I execute "dnf" command "group list Testgroup" with "success"
 And _deprecated line from "stdout" should "not start" with "Installed Groups:"
 And _deprecated line from "stdout" should "start" with "Available Groups:"
