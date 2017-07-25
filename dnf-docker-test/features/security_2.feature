Feature: Test security options for update-minimal

  @setup
  Scenario: Feature Setup
       Given _deprecated I use the repository "upgrade_1"
       When _deprecated I execute "dnf" command "-y install TestN-1.0.0-1 TestB-1.0.0-1 TestC-1.0.0-1" with "success"
       Then _deprecated transaction changes are as follows
        | State     | Packages |
        | installed | TestN-1.0.0-1,TestB-1.0.0-1,TestC-1.0.0-1 |

  Scenario: Test security options --bugfix
       When _deprecated I execute "dnf" command "-y update-minimal --bugfix" with "success"
       Then _deprecated transaction changes are as follows
         | State     | Packages |
         | upgraded  | TestN-1.0.0-3,TestC-1.0.0-2    |
