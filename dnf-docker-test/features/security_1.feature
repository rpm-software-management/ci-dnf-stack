Feature: Test security options for update

  @setup
  Scenario: Feature Setup
       Given I use the repository "upgrade_1"
       When I execute "dnf" command "-y install TestN-1.0.0-1 TestB-1.0.0-1 TestC-1.0.0-1" with "success"
       Then transaction changes are as follows
        | State     | Packages |
        | installed | TestN-1.0.0-1,TestB-1.0.0-1,TestC-1.0.0-1 |

  Scenario: Test security options --bugfix
       When I execute "dnf" command "-y update --bugfix" with "success"
       Then transaction changes are as follows
         | State     | Packages |
         | upgraded  | TestN-1.0.0-4,TestC-1.0.0-2    |
