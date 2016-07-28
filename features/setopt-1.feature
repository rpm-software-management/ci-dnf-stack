Feature: DNF/Behave test (DNF --setopt in installroot)

Scenario: Reposdir option set by --setopt in host and installroot=dockertesting3
  When I create a file "/dockertesting3/repository/install.repo" with content: "[upgrade_1-gpg-file]\nname=upgrade_1-gpg-file\nbaseurl=http://127.0.0.1/repo/upgrade_1-gpg\nenabled=1\ngpgcheck=1\ngpgkey=file:///var/www/html/repo/upgrade_1-gpg/RPM-GPG-KEY-dtest2"
  # Fail due to unavailable repository in host and installroot
  When I execute "dnf" command "--installroot=/dockertesting3 -y install TestN" with "fail"
  # Install in installroot from repository described by setopt=reposdir= (path is not affected by installroot path)
  # Fail due to path is not affected by installroot
  When I execute "dnf" command "--installroot=/dockertesting3 -y --setopt=reposdir=/repository install TestN" with "fail"
  When I execute "bash" command "rpm -q --root=/dockertesting3 TestN" with "fail"
  When I execute "dnf" command "--installroot=/dockertesting3 -y --setopt=reposdir=/dockertesting3/repository install TestN" with "success"
  When I execute "bash" command "rpm -q --root=/dockertesting3 TestN" with "success"
  Then line from "stdout" should "start" with "TestN-1.0.0-4"
  # Install in host from repository described by setopt=reposdir
  When I execute "dnf" command "-y --setopt=reposdir=/dockertesting3/repository install TestB" with "success"
  Then transaction changes are as follows
   | State        | Packages       |
   | installed    | TestB-1.0.0-2  |
  # Cleaning steps
  When I execute "dnf" command "-y remove TestB" with "success"
  Then transaction changes are as follows
   | State        | Packages       |
   | removed      | TestB-1.0.0-2  |
