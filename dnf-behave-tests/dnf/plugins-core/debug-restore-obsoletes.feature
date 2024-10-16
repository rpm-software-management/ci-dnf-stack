@not.with_os=fedora__ge__41
# The plugin was disabled by https://github.com/rpm-software-management/dnf-plugins-core/pull/541
Feature: Test for debug plugin - restoring obsoleted package


Scenario: Restoring obsoleted package
  Given I enable plugin "debug"
    And I use repository "debug-plugin"
    And I successfully execute dnf with args "install test-obsoleted-1"
    And I successfully execute dnf with args "debug-dump {context.dnf.tempdir}/dump.txt"
   When I execute dnf with args "update"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | test-obsoleter-0:2-fc29.x86_64        |
        | obsoleted     | test-obsoleted-0:1-fc29.x86_64        |
   When I execute dnf with args "debug-restore {context.dnf.tempdir}/dump.txt"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | test-obsoleted-0:1-fc29.x86_64        |
        | remove        | test-obsoleter-0:2-fc29.x86_64        |
