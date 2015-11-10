Feature: DNF/Behave test (dnf-cli)

Scenario: Install packages from repository "test-1"
 Given I use the repository "test-1"
 When I execute command "dnf install -y TestB"
 Then package "TestB" should be "installed"



