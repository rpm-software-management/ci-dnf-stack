Feature: Test error messages


@not.with_os=rhel__eq__8
@bz1888946
Scenario: Global option 'proxy_username' is set but not 'proxy_password'
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"
    And I configure dnf with
        | key            | value |
        | proxy_username | user  |
   When I execute microdnf with args "repoquery abcde"
   Then the exit code is 1
    And stderr contains "'proxy_username' is set but not 'proxy_password'"


@not.with_os=rhel__eq__8
@bz1888946
Scenario: Repository option 'proxy_username' is set but not 'proxy_password'
  Given I use repository "dnf-ci-fedora" with configuration
        | key            | value |
        | proxy_username | user  |
    And I use repository "dnf-ci-fedora-updates"
   When I execute microdnf with args "repoquery abcde"
   Then the exit code is 1
    And stderr contains "'proxy_username' is set but not 'proxy_password'"
