Feature: DNF/Behave test (dnf-cli)

Scenario: Install packages from repository "test-1"
 Given I use the repository "test-1"
 When I execute dnf command "install -y TestB" with "success"
 Then package "TestB" should be "installed"
