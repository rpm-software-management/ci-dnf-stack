Feature: Test error messages


# @dnf5
# TODO(nsella) different stderr
@bz1888946
Scenario: Global option 'proxy_username' is set but not 'proxy_password'
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"
    And I configure dnf with
        | key            | value |
        | proxy_username | user  |
   When I execute dnf with args "repoquery abcde"
   Then the exit code is 1
    And stderr contains "'proxy_username' is set but not 'proxy_password'"


# @dnf5
# TODO(nsella) different stderr
@bz1888946
Scenario: Repository option 'proxy_username' is set but not 'proxy_password'
  Given I use repository "dnf-ci-fedora" with configuration
        | key            | value |
        | proxy_username | user  |
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "repoquery abcde"
   Then the exit code is 1
    And stderr contains "'proxy_username' is set but not 'proxy_password'"

@dnf5
Scenario: Nested exception is printed when max parallel downloads are exceeded
  Given I use repository "dnf-ci-fedora"
    And I configure dnf with
        | key                    | value  |
        | max_parallel_downloads | 500    |
   When I execute dnf with args "up"
   Then the exit code is 1
    And stderr contains "Librepo error: Bad value of LRO_MAXPARALLELDOWNLOADS."
