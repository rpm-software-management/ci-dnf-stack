Feature: Install installed pkg with just name or NEVR

  @setup
  Scenario: Feature Setup
      Given I use the repository "upgrade_1"
      When I execute "dnf" command "-y install TestB-1.0.0-1  TestC-1.0.0-2 TestE-1.0.0-1" with "success"
      Then transaction changes are as follows
         | State        | Packages      |
         | installed    | TestB-1.0.0-1, TestC-1.0.0-2, TestE-1.0.0-1   |

  Scenario: Install of installed package by name (upgrade available)
      When I execute "dnf" command "-y install TestB" with "success"
      Then transaction changes are as follows
        | State        | Packages              |
        | present      | TestB-1.0.0-1         |

  Scenario: Install of installed package by name (only downgrade available)
      Given I use the repository "test-1"
      When I execute "dnf" command "-y install TestC" with "success"
      Then transaction changes are as follows
        | State        | Packages              |
        | present      | TestC-1.0.0-2         |


  Scenario: Install of installed package by NEVR of installed (upgrade available)
      Given I use the repository "test-1"
      When I execute "dnf" command "-y install TestE-1.0.0-1" with "success"
      Then transaction changes are as follows
        | State        | Packages              |
        | present      | TestE-1.0.0-1         |
