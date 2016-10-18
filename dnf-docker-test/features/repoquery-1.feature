Feature: DNF/Behave test (repoquery)

Scenario: Repoquery formated output plus --available, --installed, -Cq, -qC options
  Given I use the repository "test-1"
  When I execute "dnf" command "repoquery --available -C --queryformat %{name}-%{version}-%{release}" with "success"
  Then line from "stdout" should "not start" with "TestB-1.0.0-1"
  Then line from "stderr" should "not start" with "Last metadata expiration check"
  Then line from "stderr" should "start" with "Cache-only enabled but no cache for"
  When I execute "dnf" command "repoquery --available -qC --queryformat %{name}-%{version}-%{release}" with "success"
  Then line from "stdout" should "not start" with "TestB-1.0.0-1"
  Then line from "stderr" should "not start" with "Last metadata expiration check"
  Then line from "stderr" should "not start" with "Cache-only enabled but no cache for"
  When I execute "dnf" command "makecache" with "success"
  When I execute "dnf" command "repoquery --available -Cq --queryformat %{name}-%{version}-%{release}" with "success"
  Then line from "stdout" should "start" with "TestB-1.0.0-1"
  Then line from "stderr" should "not start" with "Cache-only enabled but no cache for"
  Then line from "stderr" should "not start" with "Last metadata expiration check"
  When I execute "dnf" command "repoquery --installed -Cq --queryformat %{name}-%{version}-%{release}" with "success"
  Then line from "stdout" should "not start" with "TestB-1.0.0-1"
  When I execute "dnf" command "repoquery -C --queryformat %{name}-%{version}-%{release}" with "success"
  Then line from "stdout" should "start" with "TestB-1.0.0-1"
  Then line from "stderr" should "start" with "Last metadata expiration check"
  When I execute "dnf" command "install -y TestB" with "success"
  Then transaction changes are as follows
    | State        | Packages   |
    | installed    | TestB      |
  When I execute "dnf" command "repoquery --available -Cq --queryformat %{name}-%{version}-%{release}" with "success"
  Then line from "stdout" should "start" with "TestB-1.0.0-1"
  When I execute "dnf" command "repoquery --installed -Cq --queryformat %{name}-%{version}-%{release}" with "success"
  Then line from "stdout" should "start" with "TestB-1.0.0-1"
  When I execute "dnf" command "--disablerepo=test-1 repoquery --available -Cq --queryformat %{name}-%{version}-%{release}" with "success"
  Then line from "stdout" should "not start" with "TestB-1.0.0-1"
