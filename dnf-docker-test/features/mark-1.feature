Feature: DNF/Behave test (dnf mark command)

Scenario: Mark package installed as dependency as user-installed
 Given I use the repository "test-1"
 # Testing standard behavior (ensure that following mark command change behavior)
 When I execute "dnf" command "install -y TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestB  |
 When I execute "dnf" command "-y remove TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | removed      | TestA, TestB  |
 # Beginning of mark command test
 When I execute "dnf" command "install -y TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestB  |
 And the file "/var/lib/dnf/yumdb/T/*TestB*/reason" should contain "dep"
 When I execute "dnf" command "mark install TestB" with "success"
 Then the file "/var/lib/dnf/yumdb/T/*TestA*/reason" should contain "user"
 When I execute "dnf" command "mark install I_doesnt_exist" with "fail"
 When I execute "dnf" command "-y remove TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | removed      | TestA         |
 # Cleaning step
 When I execute "dnf" command "-y remove TestB" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | removed      | TestB         |
