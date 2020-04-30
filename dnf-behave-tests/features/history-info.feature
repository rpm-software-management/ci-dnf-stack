Feature: Comment transaction


Background: Set up dnf-ci-fedora repository
  Given I use repository "dnf-ci-fedora"
  And I successfully execute dnf with args "install abcde --comment this_is_a_comment"


# Requires PR: https://github.com/rpm-software-management/dnf/pull/1598
@not.with_os=rhel__eq__8
@bz1773679
Scenario: history info shows comment to transaction
  When I execute dnf with args "history info"
  Then the exit code is 0
  Then stdout contains "Comment        : this_is_a_comment"
