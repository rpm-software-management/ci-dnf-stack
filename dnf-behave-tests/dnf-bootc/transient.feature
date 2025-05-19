Feature: Transient mode on a bootc system

Background: Enable repositories
  Given I use repository "bootc"

@reboot_count_1
Scenario: System should boot without any overlay (it is locked)
  When I successfully execute "ostree admin status"
  Then stdout does not contain "Unlocked:"
   And path "/usr/bin" is not writeable

@reboot_count_1
Scenario: Installing a package without overlay fails
 Given file "/usr/bin/hello" does not exist
  When I execute dnf with args "install hello"
  Then the exit code is 1
   And stdout contains lines
     """
     This bootc system is configured to be read-only. Pass --transient to perform this transaction in a transient overlay which will reset when the system reboots.
     """
   And stderr is
     """
     Operation aborted.
     """
   And file "/usr/bin/hello" does not exist

@reboot_count_1
Scenario: Install a package using --transient without any overlay procudes a warning
 Given file "/usr/bin/hello" does not exist
  When I execute dnf with args "install hello --transient"
  Then the exit code is 0
   And Transaction is following
     | Action        | Package                   |
     | install       | hello-0:1.0-1.fc29.x86_64 |
   And stdout contains lines
     """
     A transient overlay will be created on /usr that will be discarded on reboot. Keep in mind that changes to /etc and /var will still persist, and packages commonly modify these directories.
     """
   And stderr is empty
   And file "/usr/bin/hello" exists

@reboot_count_1
Scenario: After using DNF --transient, transient overlay should exist
  When I successfully execute "ostree admin status"
  Then stdout contains lines
     """
     Unlocked: transient
     """
   And path "/usr/bin" is not writeable

@reboot_count_1
Scenario: Remove and install a package using --transient with transient overlay doesn't produce warning
 Given file "/usr/bin/hello" exists
  When I execute dnf with args "remove hello --transient"
  Then the exit code is 0
   And Transaction is following
     | Action | Package                   |
     | remove | hello-0:1.0-1.fc29.x86_64 |
   And file "/usr/bin/hello" does not exist
   And stdout does not contain "transient overlay"
   And stderr is empty
  When I execute dnf with args "install hello --transient"
  Then the exit code is 0
   And Transaction is following
     | Action        | Package                   |
     | install       | hello-0:1.0-1.fc29.x86_64 |
   And stdout does not contain "transient overlay"
   And stderr is empty
   And file "/usr/bin/hello" exists

@reboot_count_1
Scenario: Removing a package without --transient and with transient overlay fails
  When I execute dnf with args "remove hello"
  Then the exit code is 1
   And stdout contains lines
     """
     This bootc system is configured to be read-only. Pass --transient to perform this transaction in a transient overlay which will reset when the system reboots.
     """
   And stderr is
     """
     Operation aborted.
     """
   And file "/usr/bin/hello" exists

@reboot_count_2
Scenario: After reboot, the transient overlay should disappear
  When I successfully execute "ostree admin status"
  Then stdout does not contain lines
     """
     Unlocked: transient
     """
   And path "/usr/bin" is not writeable
   And file "/usr/bin/hello" does not exist

@reboot_count_2
Scenario: Create writable overlay (unlock the system)
  When I successfully execute "ostree admin unlock"
   And I successfully execute "ostree admin status"
  Then stdout contains lines
     """
     Unlocked: development
     """

@reboot_count_2
Scenario: dnf install and remove work without --transient with writable overlay
 Given file "/usr/bin/hello" does not exist
  When I execute dnf with args "install hello"
  Then the exit code is 0
   And Transaction is following
     | Action  | Package                   |
     | install | hello-0:1.0-1.fc29.x86_64 |
   And file "/usr/bin/hello" exists
   And stdout does not contain "transient overlay"
   And stderr is empty
  When I execute dnf with args "remove hello"
  Then the exit code is 0
   And Transaction is following
     | Action | Package                   |
     | remove | hello-0:1.0-1.fc29.x86_64 |
   And file "/usr/bin/hello" does not exist
   And stdout does not contain "transient overlay"
   And stderr is empty

@reboot_count_2
Scenario: dnf install --transient with writable overlay doesn't warn about transient overlay
 Given file "/usr/bin/hello" does not exist
  When I execute dnf with args "install hello --transient"
  Then the exit code is 0
   And Transaction is following
     | Action        | Package                   |
     | install       | hello-0:1.0-1.fc29.x86_64 |
   And file "/usr/bin/hello" exists
   And stdout does not contain "transient overlay"
   And stderr is empty

@reboot_count_3
Scenario: After reboot, the writable overlay should disappear
  When I successfully execute "ostree admin status"
  Then stdout does not contain lines
     """
     Unlocked: development
     """
   And path "/usr/bin" is not writeable
   And file "/usr/bin/hello" does not exist

@reboot_count_3
Scenario: transient mode is configured by config option
 Given file "/usr/bin/hello" does not exist
   And I configure dnf with
       | key         | value     |
       | persistence | transient |
  When I execute dnf with args "install hello"
  Then the exit code is 0
   And Transaction is following
     | Action        | Package                   |
     | install       | hello-0:1.0-1.fc29.x86_64 |
   And stdout contains lines
     """
     A transient overlay will be created on /usr that will be discarded on reboot. Keep in mind that changes to /etc and /var will still persist, and packages commonly modify these directories.
     """
   And file "/usr/bin/hello" exists
  When I execute dnf with args "remove hello"
  Then the exit code is 0
   And Transaction is following
     | Action | Package                   |
     | remove | hello-0:1.0-1.fc29.x86_64 |
   And file "/usr/bin/hello" does not exist
   And stderr is empty

@reboot_count_3
Scenario: persist mode with transient overlay
 Given file "/usr/bin/hello" does not exist
   And I configure dnf with
       | key         | value   |
       | persistence | persist |
  When I execute dnf with args "install hello"
  Then the exit code is 1
   And stdout contains lines
     """
     Persistent transactions aren't supported on bootc systems.
     """
   And file "/usr/bin/hello" does not exist
   And stderr is
     """
     Operation aborted.
     """
