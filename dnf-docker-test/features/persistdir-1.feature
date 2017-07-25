Feature: Tracking information are stored in host persist-dir if package is installed in host

Scenario: Tracking information are stored in host persist-dir if package is installed in host
  Given _deprecated I use the repository "upgrade_1"
  When _deprecated I execute "bash" command "rm -rf /var/lib/dnf" with "success"
  Then _deprecated the path "/var/lib/dnf/" should be "absent"
  When _deprecated I execute "dnf" command "-y install TestG" with "success"
  Then _deprecated transaction changes are as follows
    | State        | Packages      |
    | installed    | TestG-1.0.0-2 |
  And _deprecated the path "/var/lib/dnf/*" should be "present"