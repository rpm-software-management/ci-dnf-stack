Feature: Tracking information are stored in host persist-dir if package is installed in host

Scenario: Tracking information are stored in host persist-dir if package is installed in host
  Given I use the repository "upgrade_1"
  When I execute "bash" command "rm -rf /var/lib/dnf" with "success"
  Then the path "/var/lib/dnf/" should be "absent"
  When I execute "dnf" command "-y install TestG" with "success"
  Then package "TestG" should be "installed"
  And the path "/var/lib/dnf/*" should be "present"