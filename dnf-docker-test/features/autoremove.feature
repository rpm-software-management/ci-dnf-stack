Feature: Autoremove unneeded packages

Scenario: When package has been installed as dependency and became non-required
 Given set of repositories
   | key        | value |
   | Repository | base  |
   | Package    | foo   |
   | Version    | 1     |
   | Release    | 1     |
   | Requires   | bar   |
   | Package    | bar   |
   | Version    | 1     |
   | Release    | 1     |
 When I execute "dnf" command "-y install foo" with "success"
 Then transaction changes are as follows
   | State     | Packages |
   | installed | foo, bar |
 Given set of repositories
   | key        | value     |
   | Repository | available |
   | Package    | foo       |
   | Version    | 2         |
   | Release    | 1         |
   | Package    | bar       |
   | Version    | 1         |
   | Release    | 1         |
 When I execute "dnf" command "-y upgrade" with "success"
 Then transaction changes are as follows
   | State        | Packages |
   | upgraded     | foo      |
   | present      | bar      |
 When I execute "dnf" command "-y autoremove" with "success"
 Then transaction changes are as follows
   | State        | Packages |
   | present      | foo      |
   | removed      | bar      |
