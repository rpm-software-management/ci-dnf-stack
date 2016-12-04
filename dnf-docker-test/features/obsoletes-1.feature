Feature: Install of obsoleted package

Scenario: Install of obsoleted package, but with presence of package with higher version that obsoleted
 Given I use the repository "obsoletes-1"
 When I execute "dnf" command "-y install TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA-3.0.0   |
   | absent       | TestB         |

Scenario: Install of obsoleted package
 Given I use the repository "obsoletes-1"
 When I execute "dnf" command "-y install TestD" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestE         |
