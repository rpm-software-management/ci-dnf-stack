Feature: Module usage help

  Scenario: I can print help using dnf module --help
       When I successfully run "dnf module --help"
       Then the command stdout should match regexp "usage: dnf module \[--legacy\]"

  Scenario: I can print help using dnf module -h
       When I successfully run "dnf module -h"
       Then the command stdout should match regexp "usage: dnf module \[--legacy\]"
