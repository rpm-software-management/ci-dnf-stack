Feature: Protected packages


# @dnf5
# TODO(nsella) different stderr
@tier1
Scenario: Package protected via setopt cannot be removed
  Given I use repository "dnf-ci-fedora"
    And I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |
   When I execute dnf with args "remove filesystem --setopt=protected_packages=filesystem"
   Then the exit code is 1
    And Transaction is empty
    And stderr contains "Problem: The operation would result in removing the following protected packages: filesystem"


Scenario: Package with protected dependency via setopt can be removed
  Given I use repository "dependency-chain"
    And I execute dnf with args "install top"
   Then the exit code is 0
    And Transaction is following
        | Action      | Package               |
        | install     | top-0:1-1.fc29.x86_64 |
        | install-dep | mid-0:2-1.fc29.x86_64 |
        | install-dep | bot-0:1-1.fc29.x86_64 |
   When I execute dnf with args "remove top --setopt=protected_packages=mid"
   Then the exit code is 0
    And Transaction is following
        | Action | Package               |
        | remove | top-0:1-1.fc29.x86_64 |


Scenario: Protected dependency via setopt cannot be removed, transaction fails
  Given I use repository "dependency-chain"
    And I execute dnf with args "install top"
   Then the exit code is 0
    And Transaction is following
        | Action      | Package               |
        | install     | top-0:1-1.fc29.x86_64 |
        | install-dep | mid-0:2-1.fc29.x86_64 |
        | install-dep | bot-0:1-1.fc29.x86_64 |
   When I execute dnf with args "remove mid --setopt=protected_packages=mid"
   Then the exit code is 1
    And Transaction is empty
    And stderr contains "Problem: The operation would result in removing the following protected packages: mid"


Scenario: Dependency of a protected package cannot be removed
  Given I use repository "dependency-chain"
    And I execute dnf with args "install top"
   Then the exit code is 0
    And Transaction is following
        | Action      | Package               |
        | install     | top-0:1-1.fc29.x86_64 |
        | install-dep | mid-0:2-1.fc29.x86_64 |
        | install-dep | bot-0:1-1.fc29.x86_64 |
   When I execute dnf with args "remove bot --setopt=protected_packages=mid"
   Then the exit code is 1
    And Transaction is empty
    And stderr is
        """
        Error: 
         Problem: The operation would result in broken dependencies for the following protected packages: mid
          - package mid-2-1.fc29.x86_64 from @System requires bot, but none of the providers can be installed
          - conflicting requests
          - problem with installed package mid-2-1.fc29.x86_64
        """


@wip
Scenario: Left over protected package installed as a dependency is not autoremoved and keeps reason
  Given I use repository "dependency-chain"
    And I successfully execute dnf with args "install top"
    And I successfully execute dnf with args "remove top --setopt=protected_packages=mid"
   When I execute dnf with args "autoremove --setopt=protected_packages=mid --debugsolver"
   Then the exit code is 0
    And stderr is
        """
        Unneeded protected package: mid-2-1.fc29.x86_64 (and its dependencies) cannot be removed, either mark it as user-installed or change protected_packages configuration option.
        """
    And stdout is
        """
        <REPOSYNC>
        Dependencies resolved.
        Nothing to do.
        Complete!
        """
    And Transaction is empty
   When I execute dnf with args "rq mid --queryformat='%{{name}}-%{{evr}} - %{{reason}}' --installed"
   Then stdout is
        """
        <REPOSYNC>
        mid-2-1.fc29 - dependency
        """


Scenario: Left over chain of dependencies with protected package is not autoremoved and keeps reason
  Given I use repository "dependency-chain"
    And I successfully execute dnf with args "install top"
    And I successfully execute dnf with args "mark remove top"
   When I execute dnf with args "autoremove --setopt=protected_packages=mid"
   Then the exit code is 0
    And stderr is
        """
        Unneeded protected package: mid-2-1.fc29.x86_64 (and its dependencies) cannot be removed, either mark it as user-installed or change protected_packages configuration option.
        """
    And Transaction is following
        | Action | Package               |
        | remove | top-0:1-1.fc29.x86_64 |
   When I execute dnf with args "rq mid --queryformat='%{{name}}-%{{evr}} - %{{reason}}' --installed"
   Then stdout is
        """
        <REPOSYNC>
        mid-2-1.fc29 - dependency
        """


Scenario: Left over protected package installed as a dependency keeps reason after upgrade
  Given I use repository "dependency-chain"
    And I successfully execute dnf with args "install top --exclude mid-2"
    And I successfully execute dnf with args "remove top --setopt=protected_packages=mid"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action      | Package               |
        | upgrade     | mid-0:2-1.fc29.x86_64 |
   When I execute dnf with args "rq mid --queryformat='%{{name}}-%{{evr}} - %{{reason}}' --installed"
   Then stdout is
        """
        <REPOSYNC>
        mid-2-1.fc29 - dependency
        """


# TODO: make protected packages work in installroots first
#Scenario: Package protected via a configuration file cannot be removed
#  Given I create and substitute file "/etc/dnf/protected.d/filesystem.conf" with
#        """
#        filesystem
#        """
#   When I execute dnf with args "remove filesystem"
#   Then the exit code is 1
#    And Transaction is empty
#    And stderr contains "Problem: The operation would result in removing the following protected packages: filesystem"


# TODO: Removal of DNF itself
# - It is performed in an installroot not to modify the host in case of
#   a failure.
# - It intentionally uses host's protected_packages to test how DNF is
#   packaged on the host.
# - It disables clean_requirements_on_remove to prevent protected dependecies
#   appearing in the error message.
@use.with_os=rhel__ge__8
Scenario: Dnf when installed protects yum package, because of dnf yum alias
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install yum"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package              |
        | install       | yum-0:3.4.3-0.x86_64 |
   When I execute dnf with args "--setopt protected_packages='glob:/etc/dnf/protected.d/*' --setopt=clean_requirements_on_remove=false remove yum"
   Then the exit code is 1
    And stderr contains "operation would result in removing the following protected packages: yum"
