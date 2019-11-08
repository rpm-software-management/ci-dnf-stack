Feature: DNF config files testing

# Scenarios, that need changes in host /etc/dnf/dnf.conf
# Scenario: Create dnf.conf file and test if host is using /etc/dnf/dnf.conf.
# Scenario: Create dnf.conf file and test if host is taking option -c /test/dnf.conf file (absolute and relative path)
# Scenario: Test without dnf.conf in installroot (dnf.conf is not taken from host)
# Scenario: Reposdir option in dnf conf.file in host

Scenario: Test removal of dependency when clean_requirements_on_remove=false
  Given I use repository "dnf-ci-fedora"
    And I do not set config file
    And I create file "/etc/dnf/dnf.conf" with
    """
    [main]
    exclude=filesystem
    clean_requirements_on_remove=false
    """
    When I execute dnf with args "install --disableexcludes=main filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | setup-0:2.12.1-1.fc29.noarch      |
        | install       | filesystem-0:3.9-2.fc29.x86_64    |
   When I execute dnf with args "remove --disableexcludes=all filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | remove        | filesystem-0:3.9-2.fc29.x86_64    |


Scenario: Test with dnf.conf in installroot (dnf.conf is taken from installroot)
  Given I use repository "dnf-ci-fedora"
    And I do not set config file
    And I create file "/etc/dnf/dnf.conf" with
    """
    [main]
    exclude=filesystem
    """
   When I execute dnf with args "install filesystem"
   Then the exit code is 1
    And stdout contains "All matches were excluded by regular filtering for argument: filesystem"
    And stderr contains "Error: Unable to find a match"


Scenario: Test with dnf.conf in installroot and --config (dnf.conf is taken from --config)
  Given I use repository "dnf-ci-fedora"
    And I create file "/etc/dnf/dnf.conf" with
    """
    [main]
    exclude=filesystem
    """
    And I create file "/test/dnf.conf" with
    """
    [main]
    exclude=dwm
    """
    And I set config file to "/test/dnf.conf"
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
   When I execute dnf with args "install dwm"
   Then the exit code is 1
    And stdout contains "All matches were excluded by regular filtering for argument: dwm"
  Given I do not set config file
   When I execute dnf with args "install dwm"
   Then the exit code is 0


Scenario: Reposdir option in dnf.conf file in installroot
  Given I create file "/etc/dnf/dnf.conf" with
    """
    [main]
    reposdir=/testrepos
    """
    And I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key     | value                                      |
        | baseurl | {context.dnf.repos_location}/dnf-ci-fedora |
    And I do not set config file
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | filesystem-0:3.9-2.fc29.x86_64    |
        | install       | setup-0:2.12.1-1.fc29.noarch      |


Scenario: Reposdir option in dnf.conf file with --config option in installroot
  Given I create file "/testdnf.conf" with
    """
    [main]
    reposdir=/testrepos
    """
    And I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key     | value                                      |
        | baseurl | {context.dnf.repos_location}/dnf-ci-fedora |
    And I set config file to "/testdnf.conf"
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | filesystem-0:3.9-2.fc29.x86_64    |
        | install       | setup-0:2.12.1-1.fc29.noarch      |


Scenario: Reposdir option in dnf.conf file with --config option in installroot is taken first from installroot then from host
  Given I create and substitute file "/testdnf.conf" with
    """
    [main]
    reposdir={context.dnf.installroot}/testrepos,/othertestrepos
    """
    And I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key     | value                                      |
        | baseurl | {context.dnf.repos_location}/dnf-ci-fedora |
    And I set config file to "/testdnf.conf"
    And I create directory "/othertestrepos"
   When I execute dnf with args "install filesystem"
   Then the exit code is 1
    And stderr contains "Error: There are no enabled repositories in "
  Given I delete directory "/othertestrepos"
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | filesystem-0:3.9-2.fc29.x86_64    |
        | install       | setup-0:2.12.1-1.fc29.noarch      |


Scenario: Reposdir option set by --setopt
  Given I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key     | value                                      |
        | baseurl | {context.dnf.repos_location}/dnf-ci-fedora |
   # fail due to unavailable repository
   When I execute dnf with args "install filesystem"
   Then the exit code is 1
   # fail due to path in setopt is not affected by installroot
   When I execute dnf with args "install --setopt=reposdir=/testrepos filesystem"
   Then the exit code is 1
   When I execute dnf with args "install --setopt=reposdir={context.dnf.installroot}/testrepos filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | filesystem-0:3.9-2.fc29.x86_64    |
	| install       | setup-0:2.12.1-1.fc29.noarch      |


@bz1512457
Scenario: Test usage of not existing config file
  Given I use repository "dnf-ci-fedora"
    And I set config file to "/etc/dnf/not_existing_dnf.conf"
    And I delete file "/etc/dnf/not_existing_dnf.conf"
   When I execute dnf with args "list"
   Then the exit code is 1
    And stderr contains "Config file.*does not exist"


@bz1722493
Scenario: Lines that contain only whitespaces do not spoil previous config options
  Given I enable plugin "config_manager"
    And I do not set config file
    And I create file "/etc/dnf/dnf.conf" with
    # the "empty" line between gpgcheck and baseurl intentionally contains spaces
    """
    [main]
    gpgcheck=0

    [testingrepo]
    gpgcheck=1
         
    baseurl=http://some.url/
    """
   When I execute dnf with args "config-manager testingrepo --dump"
   Then stdout contains lines
   """
   gpgcheck = 1
   """
