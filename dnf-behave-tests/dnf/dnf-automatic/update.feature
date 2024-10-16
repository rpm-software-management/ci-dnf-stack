@not.with_os=fedora__ge__41
# dnf-automatic disabled by https://github.com/rpm-software-management/dnf/pull/2129
@no_installroot
Feature: dnf-automatic performs update


Background:
Given I delete file "/etc/yum.repos.d/*.repo" with globs
  And I create file "/etc/dnf/dnf.conf" with
    """
    [main]
    plugins=0
    """


Scenario: dnf-automatic can update package
  Given I use repository "simple-base"
    And I successfully execute dnf with args "install labirinto"
    And I use repository "simple-updates"
   When I execute dnf-automatic with args "--installupdates"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | upgrade       | labirinto-0:2.0-1.fc29.x86_64         |


@bz1793298
Scenario: dnf-automatic fails to update when the update package is not signed
  Given I use repository "simple-base"
    And I successfully execute dnf with args "install labirinto"
    And I use repository "simple-updates" with configuration
        | key      | value  | 
        | gpgcheck | 1      |
   When I execute dnf-automatic with args "--installupdates"
   Then the exit code is 1
    And Transaction is empty


@bz1793298
Scenario: dnf-automatic fails to update when the public gpg key is not installed
  Given I use repository "simple-base"
    And I successfully execute dnf with args "install dedalo-signed-1.0"
    And I use repository "simple-updates" with configuration
        | key      | value  | 
        | gpgcheck | 1      |
   When I execute dnf-automatic with args "--installupdates"
   Then the exit code is 1
    And Transaction is empty
