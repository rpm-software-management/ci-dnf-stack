Feature: Shell install


Scenario: Using dnf shell, install an RPM
   When I open dnf shell session
    And I execute in dnf shell "repo enable dnf-ci-fedora"
    And I execute in dnf shell "install filesystem wget"
    And I execute in dnf shell "run"
   Then Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | wget-0:1.19.5-5.fc29.x86_64               |
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"
