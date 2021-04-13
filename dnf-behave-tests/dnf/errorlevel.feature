Feature: Tests for --errorlevel / -e cmdline option


Background: Enable dnf-ci-thirdparty-updates
Given I use repository "dnf-ci-thirdparty-updates"


Scenario: Test for errorlevel 0
 When I execute dnf with args "-e0 install CQRlib-extension"
 Then the exit code is 1
  And stderr is empty


Scenario: Test for errorlevel 1
 When I execute dnf with args "-e1 install CQRlib-extension"
 Then the exit code is 1
  And stderr contains "Problem: conflicting requests"
  And stderr contains "nothing provides CQRlib"


Scenario: Test for errorlevel 5
Given I use repository "dnf-ci-thirdparty"
 When I execute dnf with args "-e=5 install CQRlib-extension"
 Then the exit code is 1
  And stderr contains "package.*but none of the providers can be installed"
  And stderr contains "nothing provides abcde"


Scenario: Test for errorlevel greater than allowed value
 When I execute dnf with args "dnf -e 33 install SuperRipper"
 Then the exit code is 1
 And stderr contains "Config error:.*should be less than allowed value"
