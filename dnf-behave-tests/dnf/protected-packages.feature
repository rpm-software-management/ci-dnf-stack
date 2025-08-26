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


# @dnf5
# TODO(nsella) different stderr
Scenario: Package with protected dependency via setopt cannot be removed
  Given I use repository "dnf-ci-fedora"
    And I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |
   When I execute dnf with args "remove filesystem --setopt=protected_packages=setup"
   Then the exit code is 1
    And Transaction is empty
    And stderr contains "Problem: The operation would result in removing the following protected packages: setup"


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
