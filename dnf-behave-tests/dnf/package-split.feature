Feature: Test package splitting

@dnf5
Scenario: Install splitted package
  Given I use repository "split-package"
   When I execute dnf with args "install systemd-udev"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | systemd-udev-0:2.0-1.fc29.noarch      |


@dnf5
Scenario: Upgrade splitted package
  Given I use repository "split-package"
   When I execute dnf with args "install systemd-udev-1.0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | systemd-udev-0:1.0-1.fc29.noarch      |
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | upgrade       | systemd-udev-0:2.0-1.fc29.noarch      |
        | install       | systemd-boot-unsigned-0:2.0-1.fc29.noarch      |
