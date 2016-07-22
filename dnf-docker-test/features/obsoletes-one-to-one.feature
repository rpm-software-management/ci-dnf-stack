Feature: Obsoleting packages one-to-one

Scenario: Updating should replace one package with another
 Given set of repositories
   | key        | value  |
   | Repository | base   |
   | Package    | foo    |
   | Version    | 1      |
   | Release    | 1      |
 When I execute "dnf" command "-y install foo" with "success"
 Then transaction changes are as follows
   | State     | Packages |
   | installed | foo      |
 Given set of repositories
   | key        | value   |
   | Repository | updates |
   | Package    | bar     |
   | Version    | 2       |
   | Release    | 1       |
   | Obsoletes  | foo < 2 |
 When I execute "dnf" command "-y update" with "success"
 Then transaction changes are as follows
   | State     | Packages |
   | removed   | foo      |
   | installed | bar      |
