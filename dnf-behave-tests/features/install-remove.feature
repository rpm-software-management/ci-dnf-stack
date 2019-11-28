Feature: Install remove test

Background: Use install-remove repository
  Given I use repository "dnf-ci-install-remove"

# tea requires water and provides hot-beverage
Scenario Outline: Install remove <spec type> that requires only name
   When I execute dnf with args "install <spec>"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | tea-0:1.0-1.x86_64                |
        | install       | water-0:1.0-1.x86_64              |
   When I execute dnf with args "install tea"
   Then the exit code is 0
    And Transaction is empty
   When I execute dnf with args "remove tea"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | tea-0:1.0-1.x86_64                |
        | remove        | water-0:1.0-1.x86_64              |

Examples:
    | spec type         | spec          |
    | package           | tea           |
    | provide           | hot-beverage  |


# coffee requires water and sugar == 1
Scenario: Install remove package that requires exact version
   When I execute dnf with args "install coffee"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | coffee-0:1.0-1.x86_64             |
        | install       | sugar-0:1.0-1.x86_64              |
        | install       | water-0:1.0-1.x86_64              |
   When I execute dnf with args "remove coffee"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | coffee-0:1.0-1.x86_64             |
        | remove        | sugar-0:1.0-1.x86_64              |
        | remove        | water-0:1.0-1.x86_64              |


# chockolate  requires sugar>=2 and milk==1
Scenario: Install remove package that requires version >=
   When I execute dnf with args "install chockolate"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | chockolate-0:1.0-1.x86_64         |
        | install       | sugar-0:2.0-1.x86_64              |
        | install       | milk-0:1.0-1.x86_64               |
   When I execute dnf with args "remove chockolate"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | chockolate-0:1.0-1.x86_64         |
        | remove        | sugar-0:2.0-1.x86_64              |
        | remove        | milk-0:1.0-1.x86_64               |


# mate requires water >= 2
Scenario: Install remove package that requires version >=, not satisfiable
   When I execute dnf with args "install mate"
   Then the exit code is 1
    And stderr contains "nothing provides water >= 2 needed by mate-1.0-1.x86_64"


# both coffee and tea require water
Scenario: Install remove two package with shared dependency
   When I execute dnf with args "install tea coffee"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | coffee-0:1.0-1.x86_64             |
        | install       | tea-0:1.0-1.x86_64                |
        | install       | sugar-0:1.0-1.x86_64              |
        | install       | water-0:1.0-1.x86_64              |
   When I execute dnf with args "remove tea"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | tea-0:1.0-1.x86_64                |
        | present       | water-0:1.0-1.x86_64              |
   When I execute dnf with args "remove coffee"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | coffee-0:1.0-1.x86_64             |
        | remove        | sugar-0:1.0-1.x86_64              |
        | remove        | water-0:1.0-1.x86_64              |


Scenario: Install remove rpm file from local path
   When I execute dnf with args "install {context.scenario.repos_location}/dnf-ci-install-remove/x86_64/water-1.0-1.x86_64.rpm"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | water-0:1.0-1.x86_64              |
   When I execute dnf with args "remove water"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | water-0:1.0-1.x86_64              |


Scenario: Install remove *.rpm from local path
   When I execute dnf with args "install {context.scenario.repos_location}/dnf-ci-install-remove/x86_64/water_{{still,carbonated}}-1*.rpm"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | water_still-0:1.0-1.x86_64        |
        | install       | water_carbonated-0:1.0-1.x86_64   |
   When I execute dnf with args "remove water*"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | water_still-0:1.0-1.x86_64        |
        | remove        | water_carbonated-0:1.0-1.x86_64   |


Scenario: Install remove group
   When I execute dnf with args "install @Beverages"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | group-install | Beverages                         |
        | install       | tea-0:1.0-1.x86_64                |
        | install       | water-0:1.0-1.x86_64              |
        | install       | water_still-0:1.0-1.x86_64        |
   When I execute dnf with args "group list Beverages"
   Then the exit code is 0
    And stdout does not contain "Available Groups"
    And stdout contains "Beverages"
    And stdout contains "Installed Groups"
   When I execute dnf with args "install water_carbonated"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | water_carbonated-0:1.0-1.x86_64   |
   When I execute dnf with args "group remove Beverages"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | group-remove  | Beverages                         |
        | remove        | tea-0:1.0-1.x86_64                |
        | remove        | water-0:1.0-1.x86_64              |
        | remove        | water_still-0:1.0-1.x86_64        |
        | present       | water_carbonated-0:1.0-1.x86_64   |


Scenario: Install remove group with optional packages
   When I execute dnf with args "group install --with-optional Beverages"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | group-install | Beverages                         |
        | install       | tea-0:1.0-1.x86_64                |
        | install       | water-0:1.0-1.x86_64              |
        | install       | water_still-0:1.0-1.x86_64        |
        | install       | water_carbonated-0:1.0-1.x86_64   |
   When I execute dnf with args "remove @Beverages"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | group-remove  | Beverages                         |
        | remove        | tea-0:1.0-1.x86_64                |
        | remove        | water-0:1.0-1.x86_64              |
        | remove        | water_still-0:1.0-1.x86_64        |
        | remove        | water_carbonated-0:1.0-1.x86_64   |


Scenario: Install remove group with already installed package with dependency
   When I execute dnf with args "install tea"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | tea-0:1.0-1.x86_64                |
        | install       | water-0:1.0-1.x86_64              |
   When I execute dnf with args "install @Beverages"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | group-install | Beverages                         |
        | install       | water_still-0:1.0-1.x86_64        |
        | present       | tea-0:1.0-1.x86_64                |
        | present       | water-0:1.0-1.x86_64              |
   When I execute dnf with args "group remove Beverages"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | group-remove  | Beverages                         |
        | remove        | water_still-0:1.0-1.x86_64        |
        | present       | tea-0:1.0-1.x86_64                |
        | present       | water-0:1.0-1.x86_64              |


Scenario: Install remove group with already installed package
   When I execute dnf with args "install water_still"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | water_still-0:1.0-1.x86_64        |
   When I execute dnf with args "install @Beverages"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | group-install | Beverages                         |
        | install       | tea-0:1.0-1.x86_64                |
        | install       | water-0:1.0-1.x86_64              |
        | present       | water_still-0:1.0-1.x86_64        |
   When I execute dnf with args "group remove Beverages"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | group-remove  | Beverages                         |
        | remove        | tea-0:1.0-1.x86_64                |
        | remove        | water-0:1.0-1.x86_64              |
        | present       | water_still-0:1.0-1.x86_64        |


#Scenario: Install remove package from url
