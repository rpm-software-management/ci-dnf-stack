Feature: On-disk modulemd data are preferred over repodata in case of a conflict


Background: Setup local module defaults
  Given I use the repository "dnf-ci-fedora-modular"
    And I use the repository "dnf-ci-fedora"
    And I create file "/etc/dnf/modules.defaults.d/local_defaults.yaml" with
        """
        ---
        document: modulemd-defaults
        version: 1
        data:
          module: nodejs
          stream: 10
          profiles:
            8: [development]
            10: [development]
        ...
        """

# the repository defaults are:
#   nodejs:8/default
#   ninja:master/default

Scenario: Local system modulemd defaults override repo defaults
   When I execute dnf with args "module install nodejs"
   Then the exit code is 0
    And modules state is following
        | Module    | State     | Stream    | Profiles      |
        | nodejs    | enabled   | 10        | development   |


Scenario: No local system modulemd defaults to override repo defaults
   When I execute dnf with args "module install ninja"
   Then the exit code is 0
    And modules state is following
        | Module    | State     | Stream    | Profiles      |
        | ninja     | enabled   | master    | default       |
