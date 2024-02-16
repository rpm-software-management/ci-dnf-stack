@dnf5
Feature: Repositories with cost


Background: Use repository with cost 1000
  Given I use repository "dnf-ci-priority-1" with configuration
        | key      | value |
        | cost     | 1000  |


Scenario: Install and reinstall RPM from the lower-cost repository
   When I execute dnf with args "--nogpgcheck install flac --repofrompath=cost_900,{context.scenario.repos_location}/dnf-ci-priority-1 --setopt=cost_900.cost=900 --repofrompath=cost_1100,{context.scenario.repos_location}/dnf-ci-priority-1 --setopt=cost_1100.cost=1100"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | flac-0:1.3.3-2.fc29.x86_64                |
   When I execute dnf with args "repoquery --installed flac --qf='%{{name}} %{{from_repo}}'"
   Then the exit code is 0
    And stdout contains "flac cost_900"
   When I execute dnf with args "--nogpgcheck reinstall flac --repofrompath=cost_900,{context.scenario.repos_location}/dnf-ci-priority-1 --setopt=cost_900.cost=900 --repofrompath=cost_1100,{context.scenario.repos_location}/dnf-ci-priority-1 --setopt=cost_1100.cost=1100"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | reinstall       | flac-0:1.3.3-2.fc29.x86_64              |
   When I execute dnf with args "repoquery --installed flac --qf='%{{name}} %{{from_repo}}'"
   Then the exit code is 0
    And stdout contains "flac cost_900"
