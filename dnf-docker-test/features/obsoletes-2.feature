@xfail
Feature: Upgrade obsoleted package if higher version presented

Scenario: Upgrade of obsoleted package by package with higher version that obsoleted
 Given I use the repository "obsoletes-1"
 When I execute "dnf" command "-y install TestA-1.0.0" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA-1.0.0   |
 When I execute "dnf" command "-y upgrade" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA-3.0.0   |
