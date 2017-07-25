Feature: Upgrade obsoleted package if higher version presented

Scenario: Upgrade of obsoleted package by package with higher version that obsoleted
 Given _deprecated I use the repository "obsoletes-1"
 When _deprecated I execute "dnf" command "-y install TestA-1.0.0" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA-1.0.0   |
 When _deprecated I execute "dnf" command "-y upgrade" with "success"
 Then _deprecated transaction changes are as follows
   | State      | Packages      |
   | upgraded   | TestA-3.0.0   |
