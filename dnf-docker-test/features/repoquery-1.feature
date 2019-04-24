Feature: DNF/Behave test (repoquery)

Scenario: Repoquery formated output plus --available, --installed, -Cq, -qC options
  Given _deprecated I use the repository "test-1"
  When _deprecated I execute "dnf" command "repoquery --setopt='test-1.skip_if_unavailable=True' --available -C --queryformat %{name}-%{version}-%{release}" with "success"
  Then _deprecated line from "stdout" should "not start" with "TestB-1.0.0-1"
  Then _deprecated line from "stderr" should "not start" with "Last metadata expiration check"
  Then _deprecated line from "stderr" should "start" with "Cache-only enabled but no cache for"
  When _deprecated I execute "dnf" command "repoquery --setopt='test-1.skip_if_unavailable=True' --available -qC --queryformat %{name}-%{version}-%{release}" with "success"
  Then _deprecated line from "stdout" should "not start" with "TestB-1.0.0-1"
  Then _deprecated line from "stderr" should "not start" with "Last metadata expiration check"
  Then _deprecated line from "stderr" should "not start" with "Cache-only enabled but no cache for"
  When _deprecated I execute "dnf" command "makecache" with "success"
  When _deprecated I execute "dnf" command "repoquery --available -Cq --queryformat %{name}-%{version}-%{release}" with "success"
  Then _deprecated line from "stdout" should "start" with "TestB-1.0.0-1"
  Then _deprecated line from "stderr" should "not start" with "Cache-only enabled but no cache for"
  Then _deprecated line from "stderr" should "not start" with "Last metadata expiration check"
  When _deprecated I execute "dnf" command "repoquery --installed -Cq --queryformat %{name}-%{version}-%{release}" with "success"
  Then _deprecated line from "stdout" should "not start" with "TestB-1.0.0-1"
  When _deprecated I execute "dnf" command "repoquery -C --queryformat %{name}-%{version}-%{release}" with "success"
  Then _deprecated line from "stdout" should "start" with "TestB-1.0.0-1"
  Then _deprecated line from "stderr" should "start" with "Last metadata expiration check"
  When _deprecated I execute "dnf" command "install -y TestB" with "success"
  Then _deprecated transaction changes are as follows
    | State        | Packages   |
    | installed    | TestB      |
  When _deprecated I execute "dnf" command "repoquery --available -Cq --queryformat %{name}-%{version}-%{release}" with "success"
  Then _deprecated line from "stdout" should "start" with "TestB-1.0.0-1"
  When _deprecated I execute "dnf" command "repoquery --installed -Cq --queryformat %{name}-%{version}-%{release}" with "success"
  Then _deprecated line from "stdout" should "start" with "TestB-1.0.0-1"
  When _deprecated I execute "dnf" command "--disablerepo=test-1 repoquery --available -Cq --queryformat %{name}-%{version}-%{release}" with "success"
  Then _deprecated line from "stdout" should "not start" with "TestB-1.0.0-1"
