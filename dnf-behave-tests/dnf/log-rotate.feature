Feature: Log rotation


@bz1702690
@bz1816573
Scenario: Size and number of log files respects log_size and log_rotate options
  Given I use repository "dnf-ci-fedora"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 install glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 remove glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 install glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 remove glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 install glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 remove glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 install glibc"
    And I execute dnf with args "--setopt=log_size=1024 --setopt=log_rotate=2 remove glibc"

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
