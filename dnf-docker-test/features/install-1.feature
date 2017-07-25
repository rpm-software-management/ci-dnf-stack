Feature: DNF/Behave test (apply exclude for rpms)

Scenario: Apply exclude for rpms
  Given _deprecated I use the repository "test-1"
  When _deprecated I execute "dnf" command "install -y --exclude=TestB /repo/TestB-1*.rpm" with "fail"
  Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | absent       | TestB      |
  When _deprecated I execute "dnf" command "install -y --exclude=TestB /repo/TestB-1*.rpm /repo/TestA-1*.rpm" with "fail"
  Then _deprecated transaction changes are as follows
   | State        | Packages       |
   | absent       | TestB, TestA   |
  When _deprecated I execute "dnf" command "install -y --exclude=TestB --setopt strict=false /repo/TestB-1*.rpm /repo/TestC-1*.rpm" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages       |
   | absent       | TestB          |
   | installed    | TestC          |
  When _deprecated I execute "dnf" command "install -y --exclude=TestC /repo/TestB-1*.rpm /repo/TestA-1*.rpm" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages       |
   | installed    | TestB, TestA   |
  When _deprecated I execute "dnf" command "remove -y --exclude=TestC TestB TestA" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages       |
   | removed      | TestB, TestA   |
