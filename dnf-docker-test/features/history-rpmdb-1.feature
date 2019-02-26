Feature: DNF/Behave test rpmdb version

@bz1658120
Scenario: Compute rpmdb version in repeatable manner
  Given _deprecated I use the repository "test-1"
  When _deprecated I execute "bash" command "rpm -U /repo/TestC-1.0.0-1.noarch.rpm" with "success"
   And _deprecated I execute "dnf" command "install -y TestB" with "success"
   And _deprecated I execute "dnf" command "reinstall -y TestC" with "success"
  Then history info rpmdb version did not change
