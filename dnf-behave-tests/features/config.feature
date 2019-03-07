Feature: DNF config files testing

# Scenarios, that need changes in host /etc/dnf/dnf.conf
# Scenario: Create dnf.conf file and test if host is using /etc/dnf/dnf.conf.
# Scenario: Create dnf.conf file and test if host is taking option -c /test/dnf.conf file (absolute and relative path)
# Scenario: Test without dnf.conf in installroot (dnf.conf is not taken from host)
# Scenario: Reposdir option in dnf conf.file in host

Scenario: Test removal of dependency when clean_requirements_on_remove=false
  Given I use the repository "dnf-ci-fedora"
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
  Given I use the repository "dnf-ci-fedora"
    And I do not set config file
    And I create file "/etc/dnf/dnf.conf" with
    """
    [main]
    exclude=filesystem
    """
   When I execute dnf with args "install filesystem"
   Then the exit code is 1
    And stdout contains "No match for argument: filesystem"
    And stderr contains "Error: Unable to find a match"


Scenario: Test with dnf.conf in installroot and --config (dnf.conf is taken from --config)
  Given I use the repository "dnf-ci-fedora"
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
    And stdout contains "No match for argument: dwm"
  Given I do not set config file
   When I execute dnf with args "install dwm"
   Then the exit code is 0


Scenario: Reposdir option in dnf.conf file in installroot
  Given I use the repository "testrepo"
    And I create file "/etc/dnf/dnf.conf" with
    """
    [main]
    reposdir=/testrepos
    """
    And I create file "/testrepos/test.repo" with
    """
    [testrepo]
    name=testrepo
    baseurl=$DNF0/repos/dnf-ci-fedora
    enabled=1
    gpgcheck=0
    """
    And I do not set reposdir
    And I do not set config file
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | filesystem-0:3.9-2.fc29.x86_64    |
        | install       | setup-0:2.12.1-1.fc29.noarch      |


Scenario: Reposdir option in dnf.conf file with --config option in installroot
  Given I use the repository "testrepo"
    And I create file "/testdnf.conf" with
    """
    [main]
    reposdir=/testrepos
    """
    And I create file "/testrepos/test.repo" with
    """
    [testrepo]
    name=testrepo
    baseurl=$DNF0/repos/dnf-ci-fedora
    enabled=1
    gpgcheck=0
    """
    And I do not set reposdir
    And I set config file to "/testdnf.conf"
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | filesystem-0:3.9-2.fc29.x86_64    |
        | install       | setup-0:2.12.1-1.fc29.noarch      |


Scenario: Reposdir option in dnf.conf file with --config option in installroot is taken first from installroot then from host
  Given I use the repository "testrepo"
    And I create and substitute file "/testdnf.conf" with
    """
    [main]
    reposdir={context.dnf.installroot}/testrepos,/othertestrepos
    """
    And I create file "/testrepos/test.repo" with
    """
    [testrepo]
    name=testrepo
    baseurl=$DNF0/repos/dnf-ci-fedora
    enabled=1
    gpgcheck=0
    """
    And I do not set reposdir
    And I set config file to "/testdnf.conf"
    And I create directory "/othertestrepos"
   When I execute dnf with args "install filesystem"
   Then the exit code is 1
    And stderr contains "Error: Unknown repo: 'testrepo'"
  Given I delete directory "/othertestrepos"
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                           |
        | install       | filesystem-0:3.9-2.fc29.x86_64    |
        | install       | setup-0:2.12.1-1.fc29.noarch      |


Scenario: Reposdir option set by --setopt
  Given I use the repository "testrepo"
    And I create file "/testrepos/test.repo" with
    """
    [testrepo]
    name=testrepo
    baseurl=$DNF0/repos/dnf-ci-fedora
    enabled=1
    gpgcheck=0
    """
    And I do not set reposdir
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
