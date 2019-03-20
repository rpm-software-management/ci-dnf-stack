Feature: Test for dnf list (including all documented suboptions and yum compatibility)


Background: Enable dnf-ci-fedora repository
Given I use the repository "dnf-ci-fedora"


Scenario: dnf list nonexistentpkg
 When I execute dnf with args "list non-existent-pkg"
 Then the exit code is 1
 Then stderr contains "No matching Packages"


Scenario: List all packages available
 When I execute dnf with args "list"
 Then the exit code is 0
 Then stdout section "Available Packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"
 Then stdout section "Available Packages" contains "basesystem.noarch\s+11-6.fc29\s+dnf-ci-fedora"
 Then stdout section "Available Packages" contains "glibc.x86_64\s+2.28-9.fc29\s+dnf-ci-fedora"
 Then stdout section "Available Packages" contains "glibc-common.x86_64\s+2.28-9.fc29\s+dnf-ci-fedora"
 Then stdout section "Available Packages" contains "glibc-all-langpacks.x86_64\s+2.28-9.fc29\s+dnf-ci-fedora"


Scenario Outline: dnf list <extras alias> (installed pkgs, not from known repos)
 When I execute dnf with args "install setup"
 Then the exit code is 0
Given I disable the repository "dnf-ci-fedora"
  And I execute dnf with args "list <extras alias>"
 Then the exit code is 0
 Then stdout section "Extra Packages" contains "setup.noarch\s+2.12.1-1.fc29\s+@dnf-ci-fedora"

Examples:
      | extras alias     |
      | extras           |
      | --extras         |


Scenario: dnf list setup (when setup is installed)
 When I execute dnf with args "install setup"
 Then the exit code is 0
Given I disable the repository "dnf-ci-fedora"
 When I execute dnf with args "list setup"
 Then stdout section "Installed Packages" contains "setup.noarch\s+2.12.1-1.fc29\s+@dnf-ci-fedora"
 Then stdout does not contain "Available Packages"


Scenario: dnf list setup (when setup is not installed but it is available)
 When I execute dnf with args "list setup"
 Then stdout does not contain "Installed Packages"
 Then stdout section "Available Packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"


Scenario Outline: dnf list <installed alias> setup (when setup is installed)
 When I execute dnf with args "install setup"
 Then the exit code is 0
Given I disable the repository "dnf-ci-fedora"
 When I execute dnf with args "list <installed alias> setup"
 Then stdout section "Installed Packages" contains "setup.noarch\s+2.12.1-1.fc29\s+@dnf-ci-fedora"
 Then stdout does not contain "Available Packages"

Examples:
      | installed alias     |
      | installed           |
      | --installed         |


Scenario Outline: List <installed alias> packages from all enabled repositories 
 When I execute dnf with args "install glibc"
 Then the exit code is 0
 When I execute dnf with args "list <installed alias>"
 Then the exit code is 0
 Then stdout section "Installed Packages" contains "setup.noarch\s+2.12.1-1.fc29\s+@dnf-ci-fedora"
 Then stdout section "Installed Packages" contains "basesystem.noarch\s+11-6.fc29\s+@dnf-ci-fedora"
 Then stdout section "Installed Packages" contains "glibc.x86_64\s+2.28-9.fc29\s+@dnf-ci-fedora"
 Then stdout section "Installed Packages" contains "glibc-common.x86_64\s+2.28-9.fc29\s+@dnf-ci-fedora"
 Then stdout section "Installed Packages" contains "glibc-all-langpacks.x86_64\s+2.28-9.fc29\s+@dnf-ci-fedora"

Examples:
      | installed alias     |
      | installed           |
      | --installed         |


Scenario Outline: dnf list <available alias> setup (when setup is available)
 When I execute dnf with args "list <available alias> setup"
 Then stdout does not contain "Installed Packages"
 Then stdout section "Available Packages" contains "setup.noarch\s+2.12.1-1.fc29\s+dnf-ci-fedora"

Examples:
      | available alias     |
      | available           |
      | --available         |


Scenario: dnf list setup basesystem (when basesystem is not installed)
 When I execute dnf with args "install setup"
 Then the exit code is 0
 When I execute dnf with args "list setup basesystem"
 Then stdout section "Available Packages" contains "basesystem.noarch\s+11-6.fc29\s+dnf-ci-fedora"
 Then stdout section "Installed Packages" contains "setup.noarch\s+2.12.1-1.fc29\s+@dnf-ci-fedora"


Scenario: dnf list installed setup basesystem (when basesystem is not installed)
 When I execute dnf with args "install setup"
 Then the exit code is 0
 When I execute dnf with args "list installed setup basesystem"
 Then stdout section "Installed Packages" contains "setup.noarch\s+2.12.1-1.fc29\s+@dnf-ci-fedora"
 Then stdout does not contain "Available Packages"
 Then stdout does not contain "basesystem"


Scenario: dnf list available setup basesystem (when basesystem is available)
 When I execute dnf with args "install setup"
 Then the exit code is 0
 When I execute dnf with args "list available setup basesystem"
 Then stdout section "Available Packages" contains "basesystem.noarch\s+11-6.fc29\s+dnf-ci-fedora"
 Then stdout does not contain "Installed Packages"
 Then stdout does not contain "setup.noarch\s+2.12"


Scenario: dnf list setup basesystem (when both are installed)
 When I execute dnf with args "install setup basesystem"
 Then the exit code is 0
 When I execute dnf with args "list setup basesystem"
 Then the exit code is 0
 Then stdout section "Installed Packages" contains "setup.noarch\s+2.12.1-1.fc29\s+@dnf-ci-fedora"
 Then stdout section "Installed Packages" contains "basesystem.noarch\s+11-6.fc29\s+@dnf-ci-fedora"
 When I execute dnf with args "list installed setup basesystem"
 Then the exit code is 0
 Then stdout section "Installed Packages" contains "setup.noarch\s+2.12.1-1.fc29\s+@dnf-ci-fedora"
 Then stdout section "Installed Packages" contains "basesystem.noarch\s+11-6.fc29\s+@dnf-ci-fedora"
 Then stdout does not contain "Available Packages"
 When I execute dnf with args "list available setup.noarch basesystem.noarch"
 Then the exit code is 1
 Then stderr contains "No matching Packages to list"


Scenario: dnf list glibc\* 
 When I execute dnf with args "install glibc"
 Then the exit code is 0
Given I use the repository "dnf-ci-fedora-updates"
 When I execute dnf with args "list glibc\*"
 Then stdout section "Installed Packages" contains "glibc.x86_64\s+2.28-9.fc29\s+@dnf-ci-fedora"
 Then stdout section "Installed Packages" contains "glibc-common.x86_64\s+2.28-9.fc29\s+@dnf-ci-fedora"
 Then stdout section "Installed Packages" contains "glibc-all-langpacks.x86_64\s+2.28-9.fc29\s+@dnf-ci-fedora"
 Then stdout section "Available Packages" contains "glibc.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora"
 Then stdout does not contain "setup"


Scenario Outline: dnf list <upgrades alias>
 When I execute dnf with args "install glibc"
 Then the exit code is 0
Given I use the repository "dnf-ci-fedora-updates"
 When I execute dnf with args "list <upgrades alias>"
 Then the exit code is 0
 Then stdout section "Available Upgrades" contains "glibc.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora-updates"
 Then stdout section "Available Upgrades" contains "glibc-common.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora-updates"
 Then stdout section "Available Upgrades" contains "glibc-all-langpacks.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora-updates"

Examples:
        | upgrades alias     |
        | upgrades           |
        | --upgrades         |
        | updates            |
        

Scenario: dnf list upgrades glibc (when glibc is not installed)
Given I use the repository "dnf-ci-fedora-updates"
 When I execute dnf with args "list upgrades glibc"
 Then the exit code is 1
 Then stderr contains "No matching Packages"
 Then stdout does not contain "Upgraded Packages"


Scenario Outline: dnf list <obsoletes alias>
 When I execute dnf with args "install glibc"
 Then the exit code is 0
Given I use the repository "dnf-ci-fedora-updates"
 When I execute dnf with args "list <obsoletes alias>"
 Then the exit code is 0
 Then stdout section "Obsoleting Packages" contains "glibc.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora-updates"
 Then stdout section "Obsoleting Packages" contains "\sglibc.x86_64\s+2.28-9.fc29\s+@dnf-ci-fedora"

Examples:
      | obsoletes alias     |
      | obsoletes           |
      | --obsoletes         |


Scenario: dnf list obsoletes setup (when setup is not obsoleted)
 When I execute dnf with args "install setup"
 Then the exit code is 0
 When I execute dnf with args "list obsoletes setup"
 Then the exit code is 1
 Then stderr contains "No matching Packages"


Scenario Outline: dnf list <all alias> glibc\*
 When I execute dnf with args "install glibc"
 Then the exit code is 0
Given I use the repository "dnf-ci-fedora-updates"
 When I execute dnf with args "list <all alias>"
 Then the exit code is 0
 Then stdout section "Installed Packages" contains "glibc.x86_64\s+2.28-9.fc29\s+@dnf-ci-fedora"
 Then stdout section "Installed Packages" contains "glibc-common.x86_64\s+2.28-9.fc29\s+@dnf-ci-fedora"
 Then stdout section "Installed Packages" contains "glibc-all-langpacks.x86_64\s+2.28-9.fc29\s+@dnf-ci-fedora"
 Then stdout section "Available Packages" contains "glibc.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora"
 Then stdout section "Available Packages" contains "glibc-all-langpacks.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora"
 Then stdout does not contain "setup"

Examples:
      | all alias          |
      | all glibc\*        |
      | --all glibc\*      |

@1550560
Scenario: dnf list available pkgs with long names piped to grep
 When I execute dnf with args "clean all"
 When I execute bash with args "eval dnf -y --setopt=reposdir={context.dnf.reposdir} --disablerepo='*' --enablerepo='dnf-ci-thirdparty' --releasever={context.dnf.releasever} --installroot={context.dnf.installroot} --config={context.dnf.config} --setopt=module_platform_id={context.dnf.module_platform_id} --disableplugin='*' list available | grep 1" in directory "{context.dnf.installroot}"
 Then the exit code is 0
 Then stdout contains "forTestingPurposesWeEvenHaveReallyLongVersions.x86_64\s+1435347658326856238756823658aaaa-1\s+dnf-ci-thirdparty"
