Feature: Report missing dependencies when install attemps fails

  @setup
  Scenario: Feature Setup
      # there should be at least one enabled repo
      Given repository "base" with packages
         | Package | Tag       | Value       |
         | TestA   | Requires  | TestR       |
         | TestB   | Requires  | TestR TestS |
       When I enable repository "base"

  @bz1568965
  Scenario: Report all missing dependencies
       When I run "dnf -y install TestA TestB"
       Then the command should fail
        And the command stderr should match regexp "nothing provides TestR needed by TestA-1-1.noarch"
        And the command stderr should match regexp "nothing provides TestR needed by TestB-1-1.noarch"
        And the command stderr should match regexp "nothing provides TestS needed by TestB-1-1.noarch"
