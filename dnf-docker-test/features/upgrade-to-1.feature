Feature: Richdeps/Behave test (upgrade-to test)

Scenario: Preparation - Install packages from repository "test-1"
 Given I use the repository "test-1"
 When I execute "dnf" command "-y install TestN" with "success"
 Then transaction changes are as follows
   | State        | Packages   |
   | installed    | TestN      |

Scenario: Upgrade-to packages from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I execute "dnf" command "-y upgrade-to TestN-1.0.0-3" with "success"
 Then transaction changes are as follows
   | State        | Packages       |
   | upgraded     | TestN-1.0.0-3  |
