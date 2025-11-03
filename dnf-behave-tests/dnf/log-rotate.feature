# @dnf5
# TODO(nsella) different stdout
Feature: Log rotation


@bz1702690
@bz1816573
Scenario: Size and number of log files respects log_size and log_rotate options
  Given I use repository "dnf-ci-fedora"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 --setopt=logfilelevel=10 install glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 --setopt=logfilelevel=10 remove glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 --setopt=logfilelevel=10 install glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 --setopt=logfilelevel=10 remove glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 --setopt=logfilelevel=10 install glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 --setopt=logfilelevel=10 remove glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 --setopt=logfilelevel=10 install glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 --setopt=logfilelevel=10 remove glibc"

   When I execute "ls {context.dnf.installroot}/var/log | grep "dnf\.log""
   Then stdout is
        """
        dnf.log
        dnf.log.1
        dnf.log.2
        """
   Then size of file "var/log/dnf.log" is at most "1024"
   Then size of file "var/log/dnf.log.1" is at most "1024"
   Then size of file "var/log/dnf.log.2" is at most "1024"

   When I execute "ls {context.dnf.installroot}/var/log | grep "dnf\.rpm\.log""
   Then stdout is
        """
        dnf.rpm.log
        dnf.rpm.log.1
        dnf.rpm.log.2
        """
   Then size of file "var/log/dnf.rpm.log" is at most "1024"
   Then size of file "var/log/dnf.rpm.log.1" is at most "1024"
   Then size of file "var/log/dnf.rpm.log.2" is at most "1024"

   When I execute "ls {context.dnf.installroot}/var/log | grep "dnf\.librepo\.log""
   Then stdout is
        """
        dnf.librepo.log
        dnf.librepo.log.1
        dnf.librepo.log.2
        """
   Then size of file "var/log/dnf.librepo.log" is at most "1024"
   Then size of file "var/log/dnf.librepo.log.1" is at most "1024"
   Then size of file "var/log/dnf.librepo.log.2" is at most "1024"


@bz1910084
Scenario: Log rotation keeps file permissions
Given I use repository "dnf-ci-fedora-updates"
  And I successfully execute dnf with args "install flac"
    # Set permissions to 600
  And I successfully execute "chmod 600 {context.dnf.installroot}/var/log/dnf.log"
  And I successfully execute "chmod 600 {context.dnf.installroot}/var/log/dnf.librepo.log"
  And I successfully execute "chmod 600 {context.dnf.installroot}/var/log/dnf.rpm.log"
    # Run dnf again, so that files are rotated
 When I execute dnf with args "--setopt=log_size=100 --setopt=log_rotate=2 remove flac"
 Then the exit code is 0
  And file "/var/log/dnf.log" has mode "600"
  And file "/var/log/dnf.log.1" has mode "600"
  And file "/var/log/dnf.librepo.log" has mode "600"
  And file "/var/log/dnf.librepo.log.1" has mode "600"
  And file "/var/log/dnf.rpm.log" has mode "600"
  And file "/var/log/dnf.rpm.log.1" has mode "600"


# https://github.com/rpm-software-management/dnf/issues/2279
Scenario: Log rotation keeps ACL
Given I use repository "dnf-ci-fedora-updates"
  And I successfully execute dnf with args "install flac"
    # Set non-default ACL
  And I successfully execute "setfacl -m user:root:r {context.dnf.installroot}/var/log/dnf.log"
    # Run dnf again, so that files are rotated
 When I execute dnf with args "--setopt=log_size=1 --setopt=log_rotate=2 remove flac"
 Then the exit code is 0
  And file "/var/log/dnf.log" has ACL entry "user:root:r--"
  And file "/var/log/dnf.log.1" has ACL entry "user:root:r--"
