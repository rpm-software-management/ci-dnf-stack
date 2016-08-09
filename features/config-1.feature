Feature: DNF/Behave test (DNF config and config files in installroot)

Scenario: Reposdir option in dnf.conf file with --config option in installroot if it correctly taken first from installroot then from host
  Given I use the repository "upgrade_1"
  When I create a file "/dnf/dnf.conf" with content: "[main]\nreposdir=/var/www/html/repo/test-1-gpg,/testdir"
  When I execute "bash" command "mkdir -p  /dockertesting2/testdir" with "success"
  Then the path "/dockertesting2/testdir/" should be "present"
  # It shoud fail due to lo repository in /dockertesting2/testdir (If dir in installroot, only from installroot reposdirs)
  When I execute "dnf" command "--installroot=/dockertesting2 -c /dnf/dnf.conf -y install TestC" with "fail"
  When I execute "bash" command "rm -rf  /dockertesting2/testdir" with "success"
  Then the path "/dockertesting2/testdir/" should be "absent"
  # It give success. Repos is taken from /var/www/html/repo/test-1-gpg (no reposdir in installroot)
  When I execute "dnf" command "--installroot=/dockertesting2 -c /dnf/dnf.conf -y install TestC" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting2 TestC" with "success"
  Then line from "stdout" should "start" with "TestC-1.0.0-1"
