Feature: Enable module streams with modular dependencies


Background:
  Given I use the repository "dnf-ci-thirdparty-modular"


@bz1622566
Scenario: Enable a module and its dependencies
   When I execute dnf with args "module enable food-type:meat"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package                |
        | module-stream-enable     | food-type:meat         |
        | module-stream-enable     | ingredience:chicken    |
    And modules state is following
        | Module       | State     | Stream     | Profiles  |
        | food-type    | enabled   | meat       |           |
        | ingredience  | enabled   | chicken    |           |


Scenario: Enable a module and its dependencies by specifying profile
   When I execute dnf with args "module enable food-type:meat/default"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package                |
        | module-stream-enable     | food-type:meat         |
        | module-stream-enable     | ingredience:chicken    |
    And modules state is following
        | Module       | State     | Stream     | Profiles  |
        | food-type    | enabled   | meat       |           |
        | ingredience  | enabled   | chicken    |           |


# Commented out in case the behaviour is reverted, complementary scenario follows next
#@xfail @bz1647804
#Scenario: Disable a module and all modules that are dependent on it
#   When I execute dnf with args "module enable food-type:meat"
#   Then the exit code is 0
#    And Transaction is following
#        | Action                   | Package                |
#        | module-stream-enable     | food-type:meat         |
#        | module-stream-enable     | ingredience:chicken    |
#    And modules state is following
#        | Module       | State     | Stream     | Profiles  |
#        | food-type    | enabled   | meat       |           |
#        | ingredience  | enabled   | chicken    |           |
#   When I execute dnf with args "module disable ingredience:chicken"
#   Then the exit code is 0
#    And Transaction is following
#        | Action                   | Package                |
#        | module-disable           | food-type              |
#        | module-disable           | ingredience            |
#    And modules state is following
#        | Module       | State     | Stream     | Profiles  |
#        | food-type    | disabled  |            |           |
#        | ingredience  | disabled  |            |           |

Scenario: Module cannot be disabled if there are other enabled streams requiring it
   When I execute dnf with args "module enable food-type:meat"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package                |
        | module-stream-enable     | food-type:meat         |
        | module-stream-enable     | ingredience:chicken    |
    And modules state is following
        | Module       | State     | Stream     | Profiles  |
        | food-type    | enabled   | meat       |           |
        | ingredience  | enabled   | chicken    |           |
   When I execute dnf with args "module disable ingredience:chicken"
   Then the exit code is 1
    And stderr contains "Error: Problems in request:"
    And stderr contains "Modular dependency problems:"
    And stderr contains "Problem: module food-type:meat:1:-0.x86_64 requires module\(ingredience:chicken\)"
    And modules state is following
        | Module       | State     | Stream     | Profiles  |
        | food-type    | enabled   | meat       |           |
        | ingredience  | enabled   | chicken    |           |


Scenario: Enable the default stream of a module and its dependencies
   When I execute dnf with args "module enable food-type"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package                |
        | module-stream-enable     | food-type:fruit        |
        | module-stream-enable     | ingredience:orange     |
    And modules state is following
        | Module       | State     | Stream     | Profiles  |
        | food-type    | enabled   | fruit      |           |
        | ingredience  | enabled   | orange     |           |


# Commented out in case the behaviour is reverted, complementary scenario follows next
#@xfail @bz1648882
#Scenario: Enable a disabled module and its dependencies
#   When I execute dnf with args "module disable food-type:meat ingredience:chicken"
#   Then the exit code is 0
#    And Transaction is following
#        | Action                   | Package                |
#        | module-disable           | food-type              |
#        | module-disable           | ingredience            |
#    And modules state is following
#        | Module       | State     | Stream     | Profiles  |
#        | food-type    | disabled  |            |           |
#        | ingredience  | disabled  |            |           |
#   When I execute dnf with args "module enable food-type:meat"
#   Then the exit code is 0
#    And Transaction is following
#        | Action                   | Package                |
#        | module-enable            | food-type              |
#        | module-enable            | ingredience            |
#    And modules state is following
#        | Module       | State     | Stream     | Profiles  |
#        | food-type    | enabled   | meat       |           |
#        | ingredience  | enabled   | chicken    |           |

Scenario: Cannot enable a stream depending on a disabled module
   When I execute dnf with args "module disable food-type:meat ingredience:chicken"
   Then the exit code is 0
    And Transaction is following
        | Action                   | Package                |
        | module-disable           | food-type              |
        | module-disable           | ingredience            |
    And modules state is following
        | Module       | State     | Stream     | Profiles  |
        | food-type    | disabled  |            |           |
        | ingredience  | disabled  |            |           |
   When I execute dnf with args "module enable food-type:meat"
   Then the exit code is 1
    And stderr contains "Error: Problems in request:"
    And stderr contains "Modular dependency problems:"
    And stderr contains "module ingredience:chicken:1:-0.x86_64 is disabled"
    And modules state is following
        | Module       | State     | Stream     | Profiles  |
        | food-type    | disabled  |            |           |
        | ingredience  | disabled  |            |           |
