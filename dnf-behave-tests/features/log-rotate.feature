Feature: Log rotation


@bz1702690
Scenario: Size and number of log files respects log_size and log_rotate options
  Given I use the repository "dnf-ci-fedora"
    And I execute dnf with args "--setopt=log_size=512 --setopt=log_rotate=2 install glibc"
    And I execute dnf with args "--setopt=log_size=512 --setopt=log_rotate=2 remove glibc"
    And I execute dnf with args "--setopt=log_size=512 --setopt=log_rotate=2 install glibc"
    And I execute dnf with args "--setopt=log_size=512 --setopt=log_rotate=2 remove glibc"
    And I execute dnf with args "--setopt=log_size=512 --setopt=log_rotate=2 install glibc"
    And I execute dnf with args "--setopt=log_size=512 --setopt=log_rotate=2 remove glibc"

   When I execute "ls {context.dnf.installroot}/var/log | grep "dnf\.log""
   Then stdout is
        """
        dnf.log
        dnf.log.1
        dnf.log.2
        """
      # The log size can be higher than the maximum by the size of the last line,
      # so after cutting the last line, the size must be strictly lower than the maximum
   When I execute "head -n1 {context.dnf.installroot}/var/log/dnf.log > {context.dnf.installroot}/tmp_dnf.log"
   Then size of file "tmp_dnf.log" is less than "512"
   When I execute "head -n1 {context.dnf.installroot}/var/log/dnf.log.1 > {context.dnf.installroot}/tmp_dnf.log.1"
   Then size of file "tmp_dnf.log.1" is less than "512"
   When I execute "head -n1 {context.dnf.installroot}/var/log/dnf.log.2 > {context.dnf.installroot}/tmp_dnf.log.2"
   Then size of file "tmp_dnf.log.2" is less than "512"

   When I execute "ls {context.dnf.installroot}/var/log | grep "dnf\.rpm\.log""
   Then stdout is
        """
        dnf.rpm.log
        dnf.rpm.log.1
        dnf.rpm.log.2
        """
   When I execute "head -n1 {context.dnf.installroot}/var/log/dnf.rpm.log > {context.dnf.installroot}/tmp_dnf.rpm.log"
   Then size of file "tmp_dnf.rpm.log" is less than "512"
   When I execute "head -n1 {context.dnf.installroot}/var/log/dnf.rpm.log.1 > {context.dnf.installroot}/tmp_dnf.rpm.log.1"
   Then size of file "tmp_dnf.rpm.log.1" is less than "512"
   When I execute "head -n1 {context.dnf.installroot}/var/log/dnf.rpm.log.2 > {context.dnf.installroot}/tmp_dnf.rpm.log.2"
   Then size of file "tmp_dnf.rpm.log.2" is less than "512"
