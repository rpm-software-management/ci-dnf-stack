Feature: Tests for --debuglevel / -d cmdline option


Background: Enable repo
  Given I use repository "dnf-ci-fedora"


Scenario: Test for debuglevel 0
  When I execute dnf with args "--assumeno -d0 install setup"
  Then stderr contains "Operation aborted"
   And stdout is empty


Scenario: Test for debuglevel 1
  When I execute dnf with args "--assumeno --debuglevel=1 install setup"
  Then stdout contains "Installing:"
   And stdout does not contain "cachedir:"
   And stdout does not contain "Base command:"
   And stdout does not contain "timer: depsolve:"


Scenario: Test for debuglevel 5
  When I execute dnf with args "--assumeno -d=5 install setup"
  Then stdout contains "Installing:"
   And stdout contains "cachedir:"
   And stdout does not contain "Base command:"
   And stdout does not contain "timer: depsolve:"


Scenario: Test for debuglevel 10
  When I execute dnf with args "--assumeno --debuglevel 10 install setup"
  Then stdout contains "Installing:"
   And stdout contains "cachedir:"
   And stdout contains "Base command:"
   And stdout contains "timer: depsolve:"


Scenario: Test for debuglevel greater than allowed value
  When I execute dnf with args "--assumeno -d 100 install setup"
  Then stderr contains "Config error:.*should be less than allowed value"
   And stdout is empty
