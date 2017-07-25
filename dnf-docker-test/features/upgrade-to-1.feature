Feature: Richdeps/Behave test (upgrade-to test)

Scenario: Preparation - Install packages from repository "test-1"
 Given _deprecated I use the repository "test-1"
 When _deprecated I execute "dnf" command "-y install TestN" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | installed    | TestN      |

Scenario: Upgrade-to packages from repository "upgrade_1"
 Given _deprecated I use the repository "upgrade_1"
 When _deprecated I execute "dnf" command "-y upgrade-to TestN-1.0.0-3" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages       |
   | upgraded     | TestN-1.0.0-3  |
