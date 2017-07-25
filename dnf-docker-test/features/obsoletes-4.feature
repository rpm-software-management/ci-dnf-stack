Feature: Upgrade obsoleted package

Scenario: Upgrade of obsoleted package if package specified by version with glob (no obsoletes applied)
 Given _deprecated I use the repository "obsoletes-1"
 When _deprecated I execute "dnf" command "-y install TestF-1.0.0" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | installed    | TestF-1.0.0   |
 When _deprecated I execute "dnf" command "-y upgrade TestF-2*" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | upgraded     | TestF-2.0.1   |
