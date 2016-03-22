Feature: DNF/Behave test (dnf group mark command)

Scenario: Mark group as installed and unmark group as installed
 Given I use the repository "test-1"
 When I execute "dnf" command "group list Testgroup" with "success"
 Then line from "stdout" should "not start" with "Installed groups:"
 And line from "stdout" should "start" with "Available groups:"
 When I execute "dnf" command "group mark install Testgroup" with "success"
 # TestA-mandatory, TestC-defaults, TestD-optional
 Then transaction changes are as follows
   | State       | Packages             |
   | absent      | TestA, TestC, TestD  |
 And I execute "dnf" command "group list Testgroup" with "success"
 And line from "stdout" should "start" with "Installed groups:"
 And line from "stdout" should "not start" with "Available groups:"
 When I execute "dnf" command "group mark remove Testgroup" with "success"
 Then transaction changes are as follows
   | State       | Packages             |
   | absent      | TestA, TestC, TestD  |
 And I execute "dnf" command "group list Testgroup" with "success"
 And line from "stdout" should "not start" with "Installed groups:"
 And line from "stdout" should "start" with "Available groups:"
