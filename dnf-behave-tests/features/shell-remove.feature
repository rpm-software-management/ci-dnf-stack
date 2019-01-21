Feature: Shell remove


Background: Install flac
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | flac-0:1.3.2-8.fc29.x86_64                |


Scenario: Using dnf shell, remove an RPM
   When I open dnf shell session
    And I execute in dnf shell "repo enable dnf-ci-fedora"
    And I execute in dnf shell "remove flac"
    And I execute in dnf shell "run"
   Then Transaction is following
        | Action        | Package                                   |
        | remove        | flac-0:1.3.2-8.fc29.x86_64                |
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"
