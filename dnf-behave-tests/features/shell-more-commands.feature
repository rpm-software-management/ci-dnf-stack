Feature: Execute more commands in one transaction in dnf shell


Scenario: Using dnf shell, install and remove RPMs in one transaction
   When I open dnf shell session
    And I execute in dnf shell "repo enable dnf-ci-fedora"
    And I execute in dnf shell "install flac"
    And I execute in dnf shell "run"
   Then Transaction is following
        | Action        | Package                                   |
        | install       | flac-0:1.3.2-8.fc29.x86_64                |
    And I execute in dnf shell "install filesystem"
    And I execute in dnf shell "remove flac"
    And I execute in dnf shell "run"
   Then Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | remove        | flac-0:1.3.2-8.fc29.x86_64                |
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"
