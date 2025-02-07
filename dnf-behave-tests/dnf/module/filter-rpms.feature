@jiraRHELPLAN-6073
Feature: Filter RPMs by enabled and default module streams


Background:
Given I use repository "dnf-ci-fedora-modular"


Scenario: default from module is preferred over ursine pkg
Given I use repository "dnf-ci-fedora"
 When I execute dnf with args "install ninja-build"
 Then the exit code is 0
  And Transaction is following
    | Action                    | Package                                           |
    | install                   | ninja-build-0:1.8.2-4.module_1991+4e5efe2f.x86_64 |
    | install-dep               | setup-0:2.12.1-1.fc29.noarch                      |
    | install-dep               | glibc-common-0:2.28-9.fc29.x86_64                 |
    | install-dep               | glibc-0:2.28-9.fc29.x86_64                        |
    | install-dep               | glibc-all-langpacks-0:2.28-9.fc29.x86_64          |
    | install-dep               | filesystem-0:3.9-2.fc29.x86_64                    |
    | install-dep               | basesystem-0:11-6.fc29.noarch                     |
    | module-stream-enable      | ninja:master                                      |


Scenario: enabled module is preferred over ursine pkg
Given I use repository "dnf-ci-fedora"
 When I execute dnf with args "module enable ninja" 
 Then the exit code is 0
 When I execute dnf with args "install ninja-build"
 Then the exit code is 0
  And Transaction is following
    | Action                    | Package                                           |
    | install                   | ninja-build-0:1.8.2-4.module_1991+4e5efe2f.x86_64 |
    | install-dep               | setup-0:2.12.1-1.fc29.noarch                      |
    | install-dep               | glibc-common-0:2.28-9.fc29.x86_64                 |
    | install-dep               | glibc-0:2.28-9.fc29.x86_64                        |
    | install-dep               | glibc-all-langpacks-0:2.28-9.fc29.x86_64          |
    | install-dep               | filesystem-0:3.9-2.fc29.x86_64                    |
    | install-dep               | basesystem-0:11-6.fc29.noarch                     |


Scenario: disabled module is not used
Given I use repository "dnf-ci-fedora"
 When I execute dnf with args "module disable ninja" 
 Then the exit code is 0
 When I execute dnf with args "install ninja-build"
 Then the exit code is 0
  And Transaction is following
    | Action                    | Package                           |
    | install                   | ninja-build-0:1.8.2-5.fc29.x86_64 |


Scenario: ursine pkg is preferred over module without default
Given I use repository "dnf-ci-fedora"
 When I execute dnf with args "install dwm"
 Then the exit code is 0
  And Transaction is following
    | Action                    | Package                           |
    | install                   | dwm-0:6.1-1.x86_64                |


Scenario: RPMs from non-active streams are not available
 When I execute dnf with args "module disable nodejs:8" 
 Then I execute dnf with args "list --available dwm.x86_64"
  And the exit code is 1
 Then I execute dnf with args "list --available nodejs-devel-10.11.0"
  And the exit code is 1
 Then I execute dnf with args "list --available nodejs-devel-11.0.0"
  And the exit code is 1
 Then I execute dnf with args "list --available nodejs-10.11.0-1.module_2200+adbac02b.x86_64"
  And the exit code is 1
 Then I execute dnf with args "list --available nodejs-8.11.4-1.module_2030+42747d40.x86_64"
  And the exit code is 1
 Then I execute dnf with args "list --available dwm.x86_64"
  And the exit code is 1


# https://issues.redhat.com/browse/RHEL-62833
# destructive because of creating a user on the system
@destructive
@no_installroot
Scenario: User is warned if the module file exists but is not readable
Given I use repository "dnf-ci-fedora"
  And I successfully execute dnf with args "module enable dwm:6.0"
 # make modular config file inaccessible for a regular user
  And I successfully execute "chmod 0600 /etc/dnf/modules.d/dwm.module"
 # root user does see modular version of the package
 When I execute dnf with args "repoquery dwm"
 Then the exit code is 0
  And stdout is
  """
  dwm-0:6.0-1.module_1997+c375c79c.src
  dwm-0:6.0-1.module_1997+c375c79c.x86_64
  """
 # regular user is presented with non-modular version of the package
 # but is warned that modular filtering may not be accurate
 When I execute dnf with args "repoquery dwm" as an unprivileged user
 Then the exit code is 0
  And stdout is
  """
  dwm-0:6.1-1.src
  dwm-0:6.1-1.x86_64
  """
  And stderr contains lines
  """
  Cannot read "/etc/dnf/modules.d/dwm.module". Modular filtering may be affected.
  """
