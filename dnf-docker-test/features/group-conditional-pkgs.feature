Feature: DNF/Behave test test (Test if optional pkgs of group are installed correctly)

Scenario: Install conditional TestE if required TestG is about to be installed
  Given I use the repository "test-1"
  When I execute "dnf" command "install --assumeyes @Testgroup TestG" with "success"
  Then transaction changes are as follows
  | State        | Packages                          |
  | installed    | TestA, TestB, TestC, TestE, TestG |

Scenario: Install conditional TestE if required TestG has been already installed
  Given I use the repository "test-1"
  When I execute "dnf" command "group remove --assumeyes Testgroup" with "success"
  | State        | Packages                   |
  | removed      | TestA, TestB, TestC, TestE |
  When I execute "dnf" command "group install --assumeyes Testgroup" with "success"
  Then transaction changes are as follows
  | State        | Packages                   |
  | installed    | TestA, TestB, TestC, TestE |
