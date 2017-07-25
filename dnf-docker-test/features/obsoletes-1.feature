Feature: Install of obsoleted package

Scenario: Install of obsoleted package, but with presence of package with higher version that obsoleted
 Given _deprecated I use the repository "obsoletes-1"
 When _deprecated I execute "dnf" command "-y install TestA" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA-3.0.0   |
   | absent       | TestB         |

Scenario: Install of obsoleted package
 Given _deprecated I use the repository "obsoletes-1"
 When _deprecated I execute "dnf" command "-y install TestD" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | installed    | TestE         |
