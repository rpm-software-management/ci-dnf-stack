Feature: DNF/Behave test (DNF config and config files in installroot)

Scenario: Reposdir option in dnf.conf file with --config option in installroot if it correctly taken first from installroot then from host
  Given _deprecated I use the repository "upgrade_1"
  When _deprecated I create a file "/dnf/dnf.conf" with content: "[main]\nreposdir=/var/www/html/repo/test-1-gpg,/testdir"
  When _deprecated I execute "bash" command "mkdir -p  /dockertesting2/testdir" with "success"
  Then _deprecated the path "/dockertesting2/testdir/" should be "present"
  # It shoud fail due to lo repository in /dockertesting2/testdir (If dir in installroot, only from installroot reposdirs)
  When _deprecated I execute "dnf" command "--installroot=/dockertesting2 -c /dnf/dnf.conf -y install TestC" with "fail"
  When _deprecated I execute "bash" command "rm -rf  /dockertesting2/testdir" with "success"
  Then _deprecated the path "/dockertesting2/testdir/" should be "absent"
  # It give success. Repos is taken from /var/www/html/repo/test-1-gpg (no reposdir in installroot)
  When _deprecated I execute "dnf" command "--installroot=/dockertesting2 -c /dnf/dnf.conf -y install TestC" with "success"
  When _deprecated I execute "bash" command "rpm -q --root=/dockertesting2 TestC" with "success"
  Then _deprecated line from "stdout" should "start" with "TestC-1.0.0-1"
