Feature: Modulemd defaults are followed by dnf module commands

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
        And a file "/etc/dnf/modules.defaults.d/ModuleA.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleA
            stream: f26
            profiles:
              f26: [minimal, devel]
              f27: [minimal]
          """
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"

  Scenario: The default stream is used when enabling a module
       When I run "dnf module enable ModuleA -y"
       Then a module ModuleA config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | f26     |

  Scenario: The default streams are identified in the output of module list
       When I run "dnf module list ModuleA"
       Then the command stdout should match line by line regexp
         """
         ?Last metadata expiration check:
         modularityABDE
         Name +Stream +Profiles +Summary
         ModuleA +f26 \[d\]\[e\] +client, default, devel \[d\], minimal \[d\], serv +Module ModuleA
          +er, \.\.\. +summary
         ModuleA +f27 +client, default, devel \[d\], minimal \[d\], serv +Module ModuleA
          +er, \.\.\. +summary

         Hint:
         """

  @xfail  # bz 1618553
  Scenario: Default profiles are identified in the output of dnf info
       When I run "dnf module info ModuleA"
       Then the command stdout should match regexp "Default profiles : devel minimal"

  Scenario: Default stream and profile are used when installing a module with no enabled profile
      Given I run "dnf module disable ModuleA -y"
       When I run "dnf module install ModuleA -y"
       Then a module ModuleA config file should contain
          | Key      | Value                |
          | stream   | f26                  |
          | profiles | (set) minimal, devel |

  Scenario: Default profile(s) is used when installing a module with enabled stream
      Given I run "dnf module disable ModuleA -y"
        And I run "dnf module enable ModuleA:f27 -y"
       When I run "dnf module install ModuleA -y"
       Then a module ModuleA config file should contain
          | Key      | Value                |
          | stream   | f27                  |
          | profiles | (set) minimal, devel |
