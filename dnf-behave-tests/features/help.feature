Feature: Help command

Scenario: General help
   When I execute dnf with args "--help"
   Then the exit code is 0
    And stdout contains "List of Main Commands"
   When I execute dnf with args "--unknown-option"
   Then the exit code is 0
    And stdout contains "List of Main Commands"
   When I execute dnf with args "help"
   Then the exit code is 0
    And stdout contains "List of Main Commands"
   When I execute dnf with args "unknown-command"
   Then the exit code is 1
    And stderr contains "No such command"
    And stderr contains "It could be a DNF plugin command"


Scenario: Command help
   When I execute dnf with args "help install"
   Then the exit code is 0
   And stdout contains "usage: .+ install"
   When I execute dnf with args "install --help"
   Then the exit code is 0
    And stdout contains "usage: .+ install"
   When I execute dnf with args "install --unknown-option"
   Then the exit code is 2
   And stderr contains ".+ install: err"


@use.with_os=rhel__ge__8
@use.with_os=centos__ge__8
@use.with_os=fedora__ge__30
@use.with_os=fedora__lt__30
Scenario Outline: Help should refer to yum/dnf depending on what command was used
   When I execute "<command> <args>"
   Then the exit code is 0
    And stdout contains "usage: <command>"

Examples:
        | command  | args      |
        | dnf      | help      |
        | dnf      | --help    |
        | dnf-3    | help      |
        | dnf-3    | --help    |
        | yum      | help      |
        | yum      | --help    |


@use.with_os=rhel__eq__7
@use.with_os=centos__eq__7
@xfail
Scenario Outline: Help should refer to yum4/dnf depending on what command was used
   When I execute "<command> <args>"
   Then the exit code is 0
    And stdout contains "usage: <command>"

Examples:
        | command  | args      |
        | dnf      | help      |
        | dnf      | --help    |
        | dnf-2    | help      |
        | dnf-2    | --help    |
        | yum4     | help      |
        | yum4     | --help    |
