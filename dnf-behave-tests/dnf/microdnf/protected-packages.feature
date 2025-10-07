Feature: Protected packages


Scenario: Package protected via "protected_packages" option cannot be removed
  Given I configure dnf with
        | key                       | value            |
        | protected_packages        | filesystem       |
    And I use repository "dnf-ci-fedora"
    # "/usr" directory is needed to load rpm database (to overcome bad heuristics in libdnf created by Colin Walters)
    And I create directory "/usr"
    And I execute microdnf with args "install filesystem"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |
   When I execute microdnf with args "remove filesystem"
   Then the exit code is 1
    And stderr contains "Problem: The operation would result in removing the following protected packages: filesystem"


@bz2400488
@no_installroot
Scenario: Protected packages defined in the configuration files are merged
  Given I configure dnf with
        | key                       | value            |
        | protected_packages        | setup            |
    And I create file "/usr/share/dnf5/libdnf.conf.d/protect-dwm.conf" with
        """
        [main]
        protected_packages=dwm
        """
    And I create file "/usr/share/dnf5/libdnf.conf.d/protect-flac.conf" with
        """
        [main]
        protected_packages=flac
        """
    And I use repository "dnf-ci-fedora"
    And I execute microdnf with args "install dwm flac"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                               |
        | install       | dwm-0:6.1-1.x86_64         |
        | install       | flac-0:1.3.2-8.fc29.x86_64             |
   When I execute microdnf with args "remove dwm flac"
   Then the exit code is 1
    And stderr contains "Problem: The operation would result in removing the following protected packages: dwm, flac"
