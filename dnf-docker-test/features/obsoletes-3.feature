Feature: Upgrade obsoleted package

Scenario: Upgrade of obsoleted package
 Given I use the repository "obsoletes-1"
 When I execute "dnf" command "-y install TestF-1.0.0" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestF-1.0.0   |
 When I execute "dnf" command "-y upgrade" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestG         |
   | removed      | TestF         |
