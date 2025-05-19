Feature: Transient mode

Background: Enable repositories
  Given I use repository "bootc"

@reboot_count_1
Scenario: System should boot without transient overlay
  When I successfully execute "ostree admin status"
  Then stdout does not contain lines
     """
     Unlocked: transient
     """
   And path "/usr/bin" is not writeable

@reboot_count_1
Scenario: Install a package using --transient on a bootc system
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
   And file "/usr/bin/hello" exists

@reboot_count_1
Scenario: After using DNF --transient, the overlay should exist
  When I successfully execute "ostree admin status"
  Then stdout contains lines
     """
     Unlocked: transient
     """
   And path "/usr/bin" is not writeable

@reboot_count_2
Scenario: After reboot, the transient overlay should disappear
  When I successfully execute "ostree admin status"
  Then stdout does not contain lines
     """
     Unlocked: transient
     """
   And path "/usr/bin" is not writeable
   And file "/usr/bin/hello" does not exist
