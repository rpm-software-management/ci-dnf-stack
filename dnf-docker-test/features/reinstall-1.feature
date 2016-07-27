Feature: Reinstall won't break dependencies

Scenario: Dnf installs foo, that requires foo-libs. After reinstall of foo-libs there will be still removed foo-libs when removed foo.
 Given set of repositories
   | key        | value      |
   | Repository | base       |
   | Package    | foo        |
   | Version    | 1          |
   | Release    | 1          |
   | Requires   | foo-libs   |
   | Package    | foo-libs   |
   | Version    | 1          |
   | Release    | 1          |
 When I execute "dnf" command "-y install foo" with "success"
 Then transaction changes are as follows
   | State      | Packages      |
   | installed  | foo, foo-libs |
 When I execute "dnf" command "-y reinstall foo-libs" with "success"
 Then transaction changes are as follows
   | State    | Packages      |
   | present  | foo, foo-libs |
 When I execute "dnf" command "-y remove foo" with "success"
 Then transaction changes are as follows
   | State   | Packages      |
   | removed | foo, foo-libs |
