Feature: Transaction history undo

# scenario is expected to fail until dnf with
# https://github.com/rpm-software-management/dnf/pull/1392 is released
@not.with_os=rhel__eq__8
@bz1700529
Scenario: Undo module install with dependent userinstalled package
  Given I use the repository "dnf-ci-fedora"
    And I use the repository "dnf-ci-fedora-modular"
   # install module that contains postgresql-server
   When I execute dnf with args "module install postgresql/server"
   Then the exit code is 0
    And Transaction contains
        | Action                    | Package                                       |
        | install                   | postgresql-server-0:9.6.8-1.module_1710+b535a823.x86_64 |
   # install package, that requires postgresql-server
   When I execute dnf with args "install postgresql-test"
   Then the exit code is 0
   # try to undo module install transaction
   When I execute dnf with args "history undo last-1"
   # the transaction is not supposed to reinstall required packages, but to fail
   Then the exit code is 1
    And stdout does not contain "Reinstalling\s+: postgresql-server-9\.6\.8-1\.module_1710\+b535a823"
    And stderr contains "package postgresql-test-9\.6\.8-1\.module_1710\+b535a823\.x86_64 requires postgresql-server\(x86-64\) = 9\.6\.8-1\.module_1710\+b535a823, but none of the providers can be installed"
