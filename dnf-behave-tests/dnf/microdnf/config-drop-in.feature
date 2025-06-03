Feature: Test drop-in directories for configuration files


Scenario: Config files from the drop-in directories are loaded (microdnf reports first excluded package as not found)
  Given I use repository "dnf-ci-fedora"
    And I create file "/etc/dnf/libdnf5.conf.d/exclude-filesystem.conf" with
        """
        [main]
        exclude=filesystem
        """
    And I create file "/etc/dnf/libdnf5.conf.d/exclude-wget.conf" with
        """
        [main]
        exclude=wget
        """
    And I create file "/usr/share/dnf5/libdnf.conf.d/exclude-lame.conf" with
        """
        [main]
        exclude=lame
        """
    And I create file "/usr/share/dnf5/libdnf.conf.d/exclude-flac.conf" with
        """
        [main]
        exclude=flac
        """
   When I execute microdnf with args "install filesystem wget lame flac setup"
   Then the exit code is 1
    And stderr is
        """
        error: No package matches 'filesystem'
        """
   When I execute microdnf with args "install wget lame flac setup"
   Then the exit code is 1
    And stderr is
        """
        error: No package matches 'wget'
        """
   When I execute microdnf with args "install lame flac setup"
   Then the exit code is 1
    And stderr is
        """
        error: No package matches 'lame'
        """
   When I execute microdnf with args "install flac setup"
   Then the exit code is 1
    And stderr is
        """
        error: No package matches 'flac'
        """
   When I execute microdnf with args "install setup"
   Then the exit code is 0


Scenario: In case of the same file name, /etc/dnf/libdnf5.conf.d/... masks usr/share/dnf5/libdnf.conf.d/...
  Given I use repository "dnf-ci-fedora"
    And I create file "/usr/share/dnf5/libdnf.conf.d/exclude-dwn.conf" with
        """
        [main]
        exclude=dwm
        """
    And I create file "/etc/dnf/libdnf5.conf.d/test.conf" with
        """
        [main]
        exclude=filesystem
        """
    And I create file "/usr/share/dnf5/libdnf.conf.d/test.conf" with
        """
        [main]
        exclude=wget
        """
   When I execute microdnf with args "install dwm filesystem wget"
   Then the exit code is 1
    And stderr is
        """
        error: No package matches 'dwm'
        """
   When I execute microdnf with args "install filesystem wget"
   Then the exit code is 1
    And stderr is
        """
        error: No package matches 'filesystem'
        """
   When I execute microdnf with args "install wget"
   Then the exit code is 0


Scenario: The configs are ordered by name
  Given I use repository "dnf-ci-fedora"
    And I create file "/etc/dnf/libdnf5.conf.d/10-exclude-filesystem.conf" with
        """
        [main]
        exclude=filesystem
        """
    And I create file "/usr/share/dnf5/libdnf.conf.d/20-exclude-wget.conf" with
        """
        [main]
        exclude=wget
        """
    And I create file "/usr/share/dnf5/libdnf.conf.d/30-exclude-only-flac.conf" with
        """
        [main]
        exclude=,flac
        """
    And I create file "/etc/dnf/libdnf5.conf.d/40-exclude-lame.conf" with
        """
        [main]
        exclude=lame
        """
   When I execute microdnf with args "install filesystem wget flac lame"
   Then the exit code is 1
    And stderr is
        """
        error: No package matches 'flac'
        """
   When I execute microdnf with args "install filesystem wget lame"
   Then the exit code is 1
    And stderr is
        """
        error: No package matches 'lame'
        """
   When I execute microdnf with args "install filesystem wget"
   Then the exit code is 0


Scenario: The /etc/dnf/dnf.conf is loaded last
  Given I use repository "dnf-ci-fedora"
    And I configure dnf with
        | key                | value      |
        | exclude            | ,flac       |
    And I create file "/etc/dnf/libdnf5.conf.d/10-exclude-filesystem.conf" with
        """
        [main]
        exclude=filesystem
        """
    And I create file "/usr/share/dnf5/libdnf.conf.d/20-exclude-wget.conf" with
        """
        [main]
        exclude=wget
        """
   When I execute microdnf with args "install filesystem wget flac"
   Then the exit code is 1
    And stderr is
        """
        error: No package matches 'flac'
        """
   When I execute microdnf with args "install filesystem wget"
   Then the exit code is 0


Scenario: Fail when explicitly requested config file doesn't exist
  Given I use repository "dnf-ci-fedora"
   When I execute microdnf with args "install filesystem --config /etc/dnf/libdnf5.conf.d/test.conf"
   Then the exit code is 1
    And stderr contains "error: Failed to load /etc/dnf/libdnf5.conf.d/test.conf:"
