Feature: Test for installation of non-existent rpm or package

  @setup
  Scenario: Feature Setup
      # there should be at least one enabled repo
      Given repository "base" with packages
         | Package | Tag       | Value  |
         | TestA   | Version   | 1      |
       When I enable repository "base"

  @bz1578369
  Scenario: Try to install a non-existent rpm
       When I run "dnf -y install non-existent.rpm"
       Then the command exit code is 1
        And the command stderr should match regexp "Can not load RPM file"
        And the command stderr should match regexp "Could not open"

  Scenario: Try to install a non-existent package
       When I run "dnf -y install non-existent-package"
       Then the command exit code is 1
        And the command stdout should match regexp "No match for argument"
        And the command stderr should match regexp "Error: Unable to find a match"
