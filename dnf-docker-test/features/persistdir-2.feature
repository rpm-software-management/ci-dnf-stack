Feature: Tracking information are stored in installroot persist-dir if package is installed in installroot

Scenario: Tracking information are stored in installroot persist-dir if package is installed in installroot
  Given I use the repository "test-1"
  Then the path "/dockertesting/var/lib/dnf/" should be "absent"
  When I execute "dnf" command "--installroot=/dockertesting -y --disablerepo=* --enablerepo=test-1 install TestH" with "success"
  Then the path "/dockertesting/var/lib/dnf/*" should be "present"
  When I execute "bash" command "rpm -q --root=/dockertesting TestH" with "success"
