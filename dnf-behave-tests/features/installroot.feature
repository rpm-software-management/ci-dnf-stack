Feature: Installroot test


@force_tmp_installroot
Scenario: Install package from host repository into empty installroot
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | setup-0:2.12.1-1.fc29.noarch      |
