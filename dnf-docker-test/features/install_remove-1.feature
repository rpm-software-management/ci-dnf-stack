Feature: DNF/Behave test (install remove test)

Scenario: Install package from URL
 Given _deprecated I use the repository "test-1"
 When _deprecated I execute "dnf" command "install -y http://127.0.0.1/repo/test-1/TestB-1.0.0-1.noarch.rpm" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | installed    | TestB      |
 When _deprecated I execute "dnf" command "remove -y TestB" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | removed      | TestB      |
