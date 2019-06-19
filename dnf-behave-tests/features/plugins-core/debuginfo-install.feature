Feature: Tests for the debuginfo-install plugin

Background:
Given I use the repository "debuginfo-install"
  And I enable plugin "debuginfo-install"


@bz1585137
Scenario: reports an error for a non-existent package
 When I execute dnf with args "debuginfo-install non-existent-package"
 Then the exit code is 1
  And stdout is
      """
      <REPOSYNC>
      No match for argument: non-existent-package
      No debuginfo packages available to install
      """
  And stderr is
      """
      Error: Unable to find a match
      """

Scenario: reports an error for a package without debuginfo
 When I execute dnf with args "debuginfo-install nodebug"
 Then the exit code is 0
  And stdout is
      """
      <REPOSYNC>
      Could not find debuginfo for package: nodebug-1.0-1.x86_64
      No debuginfo packages available to install
      Dependencies resolved.
      Nothing to do.
      Complete!
      """

Scenario: installs debuginfo for package
 When I execute dnf with args "debuginfo-install foo"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                                   |
      | install       | foo-debuginfo-0:1.0-1.x86_64              |
      | install       | foo-debugsource-0:1.0-1.x86_64            |
