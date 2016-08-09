Feature: Re-install must not change "reason" of package which has been installed as dependency

  Scenario: Install foo which requires foo-libs, reinstall foo-libs, remove foo still should be removed as unneded dependency
     Given set of repositories
        | key        | value         |
        | Repository | base          |
        | Package    | foo           |
        | Version    | 1             |
        | Release    | 1             |
        | Requires   | foo-libs      |
        | Package    | foo-libs      |
        | Version    | 1             |
        | Release    | 1             |
      When I execute "dnf" command "-y install foo" with "success"
      Then transaction changes are as follows
        | State      | Packages      |
        | installed  | foo, foo-libs |
      When I execute "dnf" command "-y reinstall foo-libs" with "success"
      Then transaction changes are as follows
        | State      | Packages      |
        | present    | foo, foo-libs |
      When I execute "dnf" command "-y remove foo" with "success"
      Then transaction changes are as follows
        | State      | Packages      |
        | removed    | foo, foo-libs |
