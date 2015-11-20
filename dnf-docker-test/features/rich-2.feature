Feature: Richdeps/Behave test
  TestA requires (TestB or TestC), TestA recommends TestC
  Install TestB first with RPM, then install TestA
  with and observe if the Recommended TestC is also installed


Scenario: 
  Given I use the repository "rich-1"
  When I "install" a package "TestB" with "rpm"
  Then package "TestB" should be "installed"
  When I "install" a package "TestA" with "dnf"
  Then package "TestA, TestC" should be "installed"
