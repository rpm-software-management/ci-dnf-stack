Feature: Install installed pkg with just name or NEVR

  @setup
  Scenario: Feature Setup
      Given _deprecated I use the repository "upgrade_1"
      When _deprecated I execute "dnf" command "-y install TestB-1.0.0-1  TestC-1.0.0-2 TestE-1.0.0-1" with "success"
      Then _deprecated transaction changes are as follows
         | State        | Packages      |
         | installed    | TestB-1.0.0-1, TestC-1.0.0-2, TestE-1.0.0-1   |

  @bz1670776 @bz1671683
  Scenario: Install of installed package by name (upgrade available)
      When _deprecated I execute "dnf" command "-y install TestB" with "fail"
      When _deprecated I execute "dnf" command "-y install TestB --nobest" with "success"
      Then _deprecated transaction changes are as follows
        | State        | Packages              |
        | present      | TestB-1.0.0-1         |

  Scenario: Install of installed package by name (only downgrade available)
      Given _deprecated I use the repository "test-1"
      When _deprecated I execute "dnf" command "-y install TestC" with "success"
      Then _deprecated transaction changes are as follows
        | State        | Packages              |
        | present      | TestC-1.0.0-2         |


  Scenario: Install of installed package by NEVR of installed (upgrade available)
      Given _deprecated I use the repository "test-1"
      When _deprecated I execute "dnf" command "-y install TestE-1.0.0-1" with "success"
      Then _deprecated transaction changes are as follows
        | State        | Packages              |
        | present      | TestE-1.0.0-1         |
