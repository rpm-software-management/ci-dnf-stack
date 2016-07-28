Feature: Installing package which has been obsoleted

  Scenario: Install "owncloud" should be propagated to installing "nextcloud" as it obsoletes "owncloud"
     Given set of repositories
        | key        | value          |
        | Repository | available      |
        | Package    | owncloud       |
        | Version    | 1              |
        | Release    | 1              |
        | Package    | nextcloud      |
        | Version    | 2              |
        | Release    | 1              |
        | Provides   | owncloud = 2-1 |
        | Obsoletes  | owncloud < 2   |
      When I execute "dnf" command "-y install owncloud" with "success"
      Then transaction changes are as follows
        | State      | Packages       |
        | installed  | nextcloud      |
