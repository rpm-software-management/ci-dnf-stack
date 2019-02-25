Feature: dnf alias config file handling

  @setup
  Scenario: Configure alias
     Given I successfully run "dnf alias add foo=list"
      When I successfully run "dnf -q foo bash"
      Then the command stdout should match regexp "Installed Packages\nbash"

  Scenario: Drop in alias definition
     Given a file "/etc/dnf/aliases.d/bar.conf" with
       """
       [main]
       enabled = True
       [aliases]
       bar = list
       """
      When I successfully run "dnf -q bar bash"
      Then the command stdout should match regexp "Installed Packages\nbash"
       And the command stderr should not match regexp "No such command"

  @xfail @bz1680566
  Scenario: Disable alias definition
     Given a file "/etc/dnf/aliases.d/bar.conf" with
       """
       [main]
       enabled = False
       [aliases]
       bar = list
       """
      When I run "dnf bar bash"
      Then the command should fail
       And the command stderr should match regexp "No such command: bar."

  Scenario: Disable aliases globally
     Given a file "/etc/dnf/aliases.d/ALIASES.conf" with
       """
       [main]
       enabled = False
       """
      When I run "dnf -q foo bash"
      Then the command should fail
       And the command stderr should match regexp "No such command: foo."

