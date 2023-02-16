Feature: Test for dnf list (including all documented suboptions and yum compatibility)


Background: Enable dnf-ci-fedora repository
Given I use repository "dnf-ci-fedora"


@dnf5
Scenario: dnf list nonexistentpkg
 When I execute dnf with args "list non-existent-pkg"
 Then the exit code is 1
 Then stderr contains "No matching packages to list"


@dnf5
Scenario: List all packages available
 When I execute dnf with args "list"
 Then the exit code is 0
 Then stdout section "Available packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"
 Then stdout section "Available packages" contains "basesystem.noarch\s+11-6.fc29\s+dnf-ci-fedora"
 Then stdout section "Available packages" contains "glibc.x86_64\s+2.28-9.fc29\s+dnf-ci-fedora"
 Then stdout section "Available packages" contains "glibc-common.x86_64\s+2.28-9.fc29\s+dnf-ci-fedora"
 Then stdout section "Available packages" contains "glibc-all-langpacks.x86_64\s+2.28-9.fc29\s+dnf-ci-fedora"


@dnf5
Scenario: dnf list --extras (installed pkgs, not from known repos)
 When I execute dnf with args "install setup"
 Then the exit code is 0
Given I drop repository "dnf-ci-fedora"
  And I execute dnf with args "list --extras"
 Then the exit code is 0
 Then stdout section "Extra packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"


@dnf5
Scenario: dnf list setup (when setup is installed)
 When I execute dnf with args "install setup"
 Then the exit code is 0
Given I drop repository "dnf-ci-fedora"
 When I execute dnf with args "list setup"
 Then stdout section "Installed packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"
 Then stdout does not contain "Available packages"


@dnf5
Scenario: dnf list setup (when setup is not installed but it is available)
 When I execute dnf with args "list setup"
 Then stdout does not contain "Installed packages"
 Then stdout section "Available packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"


@dnf5
Scenario: dnf list --installed setup (when setup is installed)
 When I execute dnf with args "install setup"
 Then the exit code is 0
Given I drop repository "dnf-ci-fedora"
 When I execute dnf with args "list --installed setup"
 Then stdout section "Installed packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"
 Then stdout does not contain "Available packages"


@dnf5
Scenario: List --installed alias packages from all enabled repositories 
 When I execute dnf with args "install glibc"
 Then the exit code is 0
 When I execute dnf with args "list --installed"
 Then the exit code is 0
 Then stdout section "Installed packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"
 Then stdout section "Installed packages" contains "basesystem.noarch\s+11-6.fc29\s+dnf-ci-fedora"
 Then stdout section "Installed packages" contains "glibc.x86_64\s+2.28-9.fc29\s+dnf-ci-fedora"
 Then stdout section "Installed packages" contains "glibc-common.x86_64\s+2.28-9.fc29\s+dnf-ci-fedora"
 Then stdout section "Installed packages" contains "glibc-all-langpacks.x86_64\s+2.28-9.fc29\s+dnf-ci-fedora"


@dnf5
Scenario: dnf list --available setup (when setup is available)
 When I execute dnf with args "list --available setup"
 Then stdout does not contain "Installed packages"
 Then stdout section "Available packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"


@dnf5
Scenario: dnf list setup basesystem (when basesystem is not installed)
 When I execute dnf with args "install setup"
 Then the exit code is 0
 When I execute dnf with args "list setup basesystem"
 Then stdout section "Available packages" contains "basesystem.noarch\s+11-6.fc29\s+dnf-ci-fedora"
 Then stdout section "Installed packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"


@dnf5
Scenario: dnf list installed setup basesystem (when basesystem is not installed)
 When I execute dnf with args "install setup"
 Then the exit code is 0
 When I execute dnf with args "list --installed setup basesystem"
 Then stdout section "Installed packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"
 Then stdout does not contain "Available packages"
 Then stdout does not contain "basesystem"


# Change in behavior compared to dnf4 - Available section contains all available
# packages, installed versions are not filtered out
@dnf5
Scenario: dnf list available setup basesystem (when basesystem is available)
 When I execute dnf with args "install setup"
 Then the exit code is 0
 When I execute dnf with args "list --available setup basesystem"
 Then stdout section "Available packages" contains "basesystem.noarch\s+11-6.fc29\s+dnf-ci-fedora"
 Then stdout does not contain "Installed packages"


@dnf5
Scenario: dnf list setup basesystem (when both are installed)
 When I execute dnf with args "install setup basesystem"
 Then the exit code is 0
 When I execute dnf with args "list setup basesystem"
 Then the exit code is 0
 Then stdout section "Installed packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"
 Then stdout section "Installed packages" contains "basesystem.noarch\s+11-6.fc29\s+dnf-ci-fedora"
 When I execute dnf with args "list --installed setup basesystem"
 Then the exit code is 0
 Then stdout section "Installed packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"
 Then stdout section "Installed packages" contains "basesystem.noarch\s+11-6.fc29\s+dnf-ci-fedora"
 Then stdout does not contain "Available packages"
 When I execute dnf with args "list --available setup.noarch basesystem.noarch"
 Then the exit code is 0
 Then stdout section "Available packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"
 Then stdout section "Available packages" contains "basesystem.noarch\s+11-6.fc29\s+dnf-ci-fedora"


@dnf5
Scenario: dnf list glibc\* 
 When I execute dnf with args "install glibc"
 Then the exit code is 0
Given I use repository "dnf-ci-fedora-updates"
 When I execute dnf with args "list glibc\*"
 Then stdout section "Installed packages" contains "glibc.x86_64\s+2.28-9.fc29\s+dnf-ci-fedora"
 Then stdout section "Installed packages" contains "glibc-common.x86_64\s+2.28-9.fc29\s+dnf-ci-fedora"
 Then stdout section "Installed packages" contains "glibc-all-langpacks.x86_64\s+2.28-9.fc29\s+dnf-ci-fedora"
 Then stdout section "Available packages" contains "glibc.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora"
 Then stdout does not contain "setup"


@dnf5
Scenario Outline: dnf list <upgrades alias>
 When I execute dnf with args "install glibc"
 Then the exit code is 0
Given I use repository "dnf-ci-fedora-updates"
 When I execute dnf with args "list <upgrades alias>"
 Then the exit code is 0
 Then stdout section "Available upgrades" contains "glibc.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora-updates"
 Then stdout section "Available upgrades" contains "glibc-common.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora-updates"
 Then stdout section "Available upgrades" contains "glibc-all-langpacks.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora-updates"

Examples:
        | upgrades alias     |
        | --upgrades         |
        | --updates          |
        

@dnf5
Scenario: dnf list upgrades glibc (when glibc is not installed)
Given I use repository "dnf-ci-fedora-updates"
 When I execute dnf with args "list --upgrades glibc"
 Then the exit code is 1
 Then stderr contains "No matching packages to list"
 Then stdout does not contain "Upgraded packages"


# TODO(mblaha) --obsoletes output is not printing the obsoleted version yet
Scenario: dnf list --obsoletes
 When I execute dnf with args "install glibc"
 Then the exit code is 0
Given I use repository "dnf-ci-fedora-updates"
 When I execute dnf with args "list --obsoletes"
 Then the exit code is 0
 Then stdout section "Obsoleting packages" contains "glibc.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora-updates"
 Then stdout section "Obsoleting packages" contains "\sglibc.x86_64\s+2.28-9.fc29\s+dnf-ci-fedora"


@dnf5
Scenario: dnf list obsoletes setup (when setup is not obsoleted)
 When I execute dnf with args "install setup"
 Then the exit code is 0
 When I execute dnf with args "list --obsoletes setup"
 Then the exit code is 1
 Then stderr contains "No matching packages to list"


# TODO(mblaha) - the test does not respect dnf_command and runs dnf4 in subprocess
@1550560
Scenario: dnf list available pkgs with long names piped to grep
Given I use repository "dnf-ci-thirdparty"
 When I execute dnf with args "clean all"
 When I execute "eval dnf -y --releasever={context.dnf.releasever} --installroot={context.dnf.installroot} --setopt=module_platform_id={context.dnf.module_platform_id} --disableplugin='*' list available | grep 1" in "{context.dnf.installroot}"
 Then the exit code is 0
 Then stdout contains "forTestingPurposesWeEvenHaveReallyLongVersions.x86_64\s+1435347658326856238756823658aaaa-1\s+dnf-ci-thirdparty"


@dnf5
@bz1800342
Scenario: dnf list respects repo priorities
  Given I use repository "dnf-ci-fedora-updates" with configuration
        | key           | value   |
        # lower priority than default
        | priority      | 100     |
   When I execute dnf with args "list flac.x86_64"
   Then the exit code is 0
    And stdout section "Available packages" contains "flac.x86_64\s+1.3.2-8.fc29\s+dnf-ci-fedora"
    And stdout section "Available packages" does not contain "1.3.3"


@dnf5
Scenario: dnf list --showduplicates lists all (even from lower-priority repo)
  Given I use repository "dnf-ci-fedora-updates" with configuration
        | key           | value   |
        # lower priority than default
        | priority      | 100     |
   When I execute dnf with args "list flac.x86_64 --showduplicates"
   Then the exit code is 0
    And stdout section "Available packages" contains "flac.x86_64\s+1.3.2-8.fc29\s+dnf-ci-fedora"
    And stdout section "Available packages" contains "flac.x86_64\s+1.3.3-1.fc29\s+dnf-ci-fedora-updates"
    And stdout section "Available packages" contains "flac.x86_64\s+1.3.3-2.fc29\s+dnf-ci-fedora-updates"
    And stdout section "Available packages" contains "flac.x86_64\s+1.3.3-3.fc29\s+dnf-ci-fedora-updates"


@dnf5
@bz1800342
Scenario: dnf list doesn't show any available packages when there are no upgrades in the highest-priority repo
  Given I use repository "dnf-ci-fedora-updates" with configuration
        | key           | value   |
        # lower priority than default
        | priority      | 100     |
    And I successfully execute dnf with args "install flac-1.3.3-1.fc29"
   When I execute dnf with args "list flac.x86_64"
   Then the exit code is 0
    And stdout section "Available packages" does not contain "flac"


@dnf5
Scenario: dnf list shows available packages when there are upgrades in the highest-priority repo
  Given I use repository "dnf-ci-fedora-updates" with configuration
        | key           | value   |
        # higher priority than default
        | priority      | 1       |
    And I successfully execute dnf with args "install flac-1.3.3-1.fc29"
   When I execute dnf with args "list flac.x86_64"
   Then the exit code is 0
    And stdout section "Installed packages" contains "flac.x86_64\s+1.3.3-1.fc29\s+dnf-ci-fedora-updates"
    And stdout section "Available packages" contains "flac.x86_64\s+1.3.3-3.fc29\s+dnf-ci-fedora-updates"
    And stdout section "Available packages" does not contain "1.3.2"
    And stdout section "Available packages" does not contain "1.3.3-1"
    And stdout section "Available packages" does not contain "1.3.3-2"


@dnf5
Scenario: dnf list doesn't show package with same nevra from lower-priority repo
  Given I configure a new repository "dnf-ci-fedora2" with
        | key     | value                                          |
        | baseurl | file://{context.dnf.repos[dnf-ci-fedora].path} |
        # lower priority than default
        | priority      | 100                                      |
   When I execute dnf with args "list flac.x86_64"
   Then the exit code is 0
    And stdout section "Available packages" contains "flac.x86_64\s+1.3.2-8.fc29\s+dnf-ci-fedora"
    And stdout section "Available packages" does not contain "dnf-ci-fedora2"


# TODO(mblaha) --security not supported for list command
@bz2124483
Scenario: dnf list updates --security shows upgrades as available when it changes arch from noarch
Given I use repository "security-upgrade"
  And I execute dnf with args "install change-arch-noarch-1-1.noarch"
 When I execute dnf with args "list upgrades --security"
 Then the exit code is 0
  And stdout is
  """
  <REPOSYNC>
  Available Upgrades
  change-arch-noarch.x86_64                  2-2                  security-upgrade
  """


# TODO(mblaha) --security not supported for list command
@bz2124483
Scenario: dnf list updates --security doesn't shnow an upgrade when it would require an arch change (when its not noarch)
Given I use repository "security-upgrade"
  And I successfully execute dnf with args "install change-arch-1-1.i686"
  # Make sure change-arch-2-2.x86_64 is available since we are testing we don't list it.
  # It also has to have an available advisory. (We cannot verify that here because the updateinfo command is bugged when dealing with arch changes)
  And I successfully execute dnf with args "repoquery change-arch-2-2.x86_64"
  Then stdout is
  """
  <REPOSYNC>
  change-arch-0:2-2.x86_64
  """
 When I execute dnf with args "list upgrades --security"
 Then the exit code is 0
  And stdout is
  """
  <REPOSYNC>
  """
