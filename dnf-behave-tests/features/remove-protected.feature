Feature: Do not remove protected RPMs

@use.with_os=rhel__ge__8
Scenario: Cannot remove protected package yum
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install yum"
   Then the exit code is 0
   When I execute dnf with args "remove yum"
   Then the exit code is 1
    And stderr contains "operation would result in removing the following protected packages: yum"
