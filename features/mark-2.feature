Feature: DNF/Behave test (dnf mark command)

Scenario: Mark package installed as user-installed as dependency
 Given I use the repository "test-1"
 # TestK and TestL requires TestM
 When I execute "dnf" command "install -y TestK TestL" with "success"
 Then transaction changes are as follows
   | State        | Packages             |
   | installed    | TestK, TestL, TestM  |
 And the file "/var/lib/dnf/yumdb/T/*TestK*/reason" should contain "user"
 When I execute "dnf" command "mark remove TestK" with "success"
 Then the file "/var/lib/dnf/yumdb/T/*TestK*/reason" should contain "dep"
 When I execute "dnf" command "-y autoremove" with "success"
 Then transaction changes are as follows
   | State        | Packages   |
   | removed      | TestK      |
 # Cleaning step
 When I execute "dnf" command "-y remove TestL" with "success"
 Then transaction changes are as follows
   | State        | Packages       |
   | removed      | TestL, TestM   |
