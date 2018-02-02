@xfail
Feature: Module info

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
        And I run steps from file "modularity-repo-2.setup"
       When I enable repository "modularityABDE"
        And I enable repository "modularityX"
        And I successfully run "dnf -y module enable ModuleA:f26"
        And I successfully run "dnf -y module install ModuleA/client"
        And I successfully run "dnf -y module enable ModuleX:f26"
        And I successfully run "dnf -y module install ModuleX/default"
        And I successfully run "dnf makecache"

  Scenario: Get info for an enabled stream, only module name specified
       When I successfully run "dnf module info ModuleA"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           
           Name +: +ModuleA
           Stream +: +f26
           Version +: +2
           Profiles +: +client default devel minimal server
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-1-2.modA.noarch
            +: +TestB-1-1.modA.noarch
            +: +TestC-1-2.modA.noarch
            +: +TestD-1-1.modA.noarch
           """

  Scenario: Get info for an enabled stream, module name and stream specified
       When I successfully run "dnf module info ModuleA:f26"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           
           Name +: +ModuleA
           Stream +: +f26
           Version +: +2
           Profiles +: +client default devel minimal server
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-1-2.modA.noarch
            +: +TestB-1-1.modA.noarch
            +: +TestC-1-2.modA.noarch
            +: +TestD-1-1.modA.noarch
           """

  # expected to fail, should be updated when bz1540189 will be resolved
  Scenario: Get info for an installed profile, module name and profile specified
       When I successfully run "dnf module info ModuleA/client"
       Then the command stdout should match regexp "profile specific info or a warning"

  # expected to fail, should be updated when bz1540189 will be resolved
  Scenario: Get info for an installed profile, module name, stream and profile specified
       When I successfully run "dnf module info ModuleA:f26/client"
       Then the command stdout should match regexp "profile specific info or a warning"

  # expected to fail, should be updated when bz1540189 will be resolved
  Scenario: Get error message when info for non-existent profile is requested
       When I run "dnf module info ModuleA:f26/non-existent-profile"
       Then the command should fail

  Scenario: Get error message when info for non-existent module is requested
       When I run "dnf module info non-existent-module"
       Then the command should fail
        And the command stderr should match regexp "Error: No such module"

  Scenario: Get info for a disabled stream, module name and stream specified
       When I successfully run "dnf module info ModuleB:f26"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           
           Name +: +ModuleB
           Stream +: +f26
           Version +: +2
           Profiles +: +default
           Repo +: +modularityABDE
           Summary +: +Module ModuleB summary
           Description +: +Module ModuleB description
           Artifacts +: +TestG-1-2.modB.noarch
            +: +TestI-1-1.modB.noarch
           """

  # expected to fail, should pass when bz1540165 will be resolved
  Scenario: Get info for a disabled stream, when another stream of the same module is locked
       When I successfully run "dnf module lock ModuleA:f26"
        And I successfully run "dnf module info ModuleA:f27"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           
           Name +: +ModuleA
           Stream +: +f27
           Version +: +1
           Profiles +: +client default devel minimal server
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-2-1.modA.noarch
            +: +TestB-2-1.modA.noarch
            +: +TestC-2-1.modA.noarch
            +: +TestD-2-1.modA.noarch
           """

  Scenario: Get error when info for a disabled stream is requested and only module name is specified
       When I run "dnf module info ModuleB"
       Then the command should fail
        And the command stderr should match regexp "Error: No stream specified.*"

  Scenario: Get info for two enabled modules from different repos
       When I successfully run "dnf module info ModuleA ModuleX"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           
           Name +: +ModuleA
           Stream +: +f26
           Version +: +2
           Profiles +: +client default devel minimal server
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-1-2.modA.noarch
            +: +TestB-1-1.modA.noarch
            +: +TestC-1-2.modA.noarch
            +: +TestD-1-1.modA.noarch
           
           Name +: +ModuleX
           Stream +: +f26
           Version +: +1
           Profiles +: +default
           Repo +: +modularityX
           Summary +: +Module ModuleX summary
           Description +: +Module ModuleX description
           Artifacts +: +TestX-1-1.modX.noarch
           """

  # expected to fail, should be updated when bz1541332 will be resolved
  Scenario: Get info for two modules, one of them non-existent
       When I run "dnf module info non-existent-module ModuleX"
       Then the command should fail
        And the command stderr should match regexp "Error: No such module"
        And the command stdout should match regexp "Summary.*Module ModuleX summary"

  # expected to fail, should be updated when the issue will be resolved
  Scenario: Run 'dnf module info' without further argument
       When I run "dnf module info"
       Then the command should fail
        And the command stderr should match regexp "Error: dnf module info: too few arguments"
        And the command stderr should match regexp "usage: dnf module info"
