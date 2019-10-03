Feature: Modular filtering must provide onlu relevant source packages

Background:
  Given I use repository "dnf-ci-thirdparty-modular"

@bz1702729
Scenario: Check that only module packages including src are available
   When I execute dnf with args "module enable berry-source:wood"
   Then the exit code is 0
    And modules state is following
        | Module       | State     | Stream     | Profiles  |
        | berry-source | enabled   | wood       |           |
   When I execute dnf with args "repoquery berry"
   Then the exit code is 0
    And stdout is
        """
        berry-0:1.0-1.wood.src
        berry-0:1.0-1.wood.x86_64
        """

@bz1702729
Scenario: Check that only module packages including src are available
 When I execute dnf with args "module enable berry-source:garden"
 Then the exit code is 0
  And modules state is following
      | Module       | State     | Stream     | Profiles  |
      | berry-source | enabled   | garden     |           |
 When I execute dnf with args "repoquery berry"
 Then the exit code is 0
  And stdout is
      """
      berry-0:1.0-1.garden.src
      berry-0:1.0-1.garden.x86_64
      """
