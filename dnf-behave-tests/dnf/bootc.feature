@bootc
@destructive
@no_installroot
Feature: Bootc plugin

Background: Enable repositories
  Given I use repository "simple-base"

@reboot_count_1
Scenario: Install a package using --transient on a bootc system
  When I execute dnf with args "install labirinto --transient"
  Then the exit code is 0
   And Transaction is following
     | Action        | Package                       |
     | install       | labirinto-0:1.0-1.fc29.x86_64 |
   And stdout contains lines
     """
     A transient overlay will be created on /usr that will be discarded on reboot. Keep in mind that changes to /etc and /var will still persist, and packages commonly modify these directories.
     """
