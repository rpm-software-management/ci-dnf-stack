Feature: Test swap of conflicting pacakges


Background: Enable repositories
  Given I use repository "swap-conflicts"


@RHEL-141449
Scenario: Swap conflicting packages
  When I execute dnf with args "install swaptest"
  Then the exit code is 0
   And Transaction is following
       | Action        | Package                          |
       | install       | swaptest-2-0.noarch              |
       | install-dep   | libswaptest-2-0.noarch           |
  When I execute dnf with args "swap libswaptest libswaptest-minimal"
  Then the exit code is 0
   And Transaction is following
       | Action        | Package                          |
       | remove        | libswaptest-2-0.noarch           |
       | install       | libswaptest-minimal-2-0.noarch   |
