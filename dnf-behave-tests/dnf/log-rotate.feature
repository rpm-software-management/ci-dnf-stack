# @dnf5
# TODO(nsella) different stdout
Feature: Log rotation


@xfail
# https://github.com/rpm-software-management/dnf5/issues/1818
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

   When I execute "ls {context.dnf.installroot}/var/log | grep "dnf5\.log""
   Then stdout is
        """
        dnf5.log
        dnf5.log.1
        dnf5.log.2
        """
   Then size of file "var/log/dnf5.log" is at most "1024"
   Then size of file "var/log/dnf5.log.1" is at most "1024"
   Then size of file "var/log/dnf5.log.2" is at most "1024"
