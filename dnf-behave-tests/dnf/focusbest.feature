@dnf5
Feature: Always use the latest packages even for dependecies


# The focusbest behavior has been reverted.
# It might become an option in the future.
@xfail
Scenario: prefer installing latests dependencies rather than smaller transaction
  Given I use repository "focusbest"
    And I successfully execute dnf with args "install krb5-libs-1.0"
   When I execute dnf with args "install ipa-client"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                         |
        | install       | ipa-client-0:1.0-1.fc29.x86_64  |
        | install-dep   | krb5-pkinit-0:2.0-1.fc29.x86_64 |
        | upgrade       | krb5-libs-0:2.0-1.fc29.x86_64   |
    And stderr is
    """
    Warning: skipped PGP checks for 3 packages from repository: focusbest
    """


Scenario: if latests dependencies are not possible to install fall back to lower versions without errors
  Given I use repository "focusbest"
    And I successfully execute dnf with args "install krb5-libs-1.0"
    When I execute dnf with args "install ipa-client -x krb5-libs-2.0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                         |
        | install       | ipa-client-0:1.0-1.fc29.x86_64  |
        | install-dep   | krb5-pkinit-0:1.0-1.fc29.x86_64 |
    And stderr is
    """
    Warning: skipped PGP checks for 2 packages from repository: focusbest
    """
