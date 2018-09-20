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

  Scenario: Get info for a module, only module name specified
       When I successfully run "dnf module info ModuleA"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           Name +: +ModuleA
           Stream +: +f26
           Version +: +1
           Profiles +: +client \[i\], server, devel, minimal, default
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-0:1-1.modA.noarch
            +: +TestB-0:1-1.modA.noarch
            +: +TestC-0:1-1.modA.noarch
            +: +TestD-0:1-1.modA.noarch
           
           Name +: +ModuleA
           Stream +: +f26 \[e\]
           Version +: +2
           Profiles +: +client \[i\], server, devel, minimal, default
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-0:1-2.modA.noarch
            +: +TestB-0:1-1.modA.noarch
            +: +TestC-0:1-2.modA.noarch
            +: +TestD-0:1-1.modA.noarch
           
           Name +: +ModuleA
           Stream +: +f27
           Version +: +1
           Profiles +: +client, server, devel, minimal, default
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-0:2-1.modA.noarch
            +: +TestB-0:2-1.modA.noarch
            +: +TestC-0:2-1.modA.noarch
            +: +TestD-0:2-1.modA.noarch
           
           Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled
           """

  Scenario: Get info for an enabled stream, module name and stream specified
       When I successfully run "dnf module info ModuleA:f26"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           Name +: +ModuleA
           Stream +: +f26 \[e\]
           Version +: +1
           Profiles +: +client \[i\], server, devel, minimal, default
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-0:1-1.modA.noarch
            +: +TestB-0:1-1.modA.noarch
            +: +TestC-0:1-1.modA.noarch
            +: +TestD-0:1-1.modA.noarch
           
           Name +: +ModuleA
           Stream +: +f26 \[e\]
           Version +: +2
           Profiles +: +client \[i\], server, devel, minimal, default
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-0:1-2.modA.noarch
            +: +TestB-0:1-1.modA.noarch
            +: +TestC-0:1-2.modA.noarch
            +: +TestD-0:1-1.modA.noarch
           
           Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled
           """
  # bz1540189
  Scenario: Get info for an installed profile, module name and profile specified
       When I successfully run "dnf module info ModuleA/client"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           Ignoring unnecessary profile: 'ModuleA/client'
           Name +: +ModuleA
           Stream +: +f26 \[e\]
           Version +: +1
           Profiles +: +client \[i\], server, devel, minimal, default
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-0:1-1.modA.noarch
            +: +TestB-0:1-1.modA.noarch
            +: +TestC-0:1-1.modA.noarch
            +: +TestD-0:1-1.modA.noarch
           
           Name +: +ModuleA
           Stream +: +f26 \[e\]
           Version +: +2
           Profiles +: +client \[i\], server, devel, minimal, default
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-0:1-2.modA.noarch
            +: +TestB-0:1-1.modA.noarch
            +: +TestC-0:1-2.modA.noarch
            +: +TestD-0:1-1.modA.noarch
           
           Name +: +ModuleA
           Stream +: +f27
           Version +: +1
           Profiles +: +client, server, devel, minimal, default
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-0:2-1.modA.noarch
            +: +TestB-0:2-1.modA.noarch
            +: +TestC-0:2-1.modA.noarch
            +: +TestD-0:2-1.modA.noarch
 
           Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled
           """

  # z1540189
  Scenario: Get info for an installed profile, module name, stream and profile specified
       When I successfully run "dnf module info ModuleA:f26/client"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           Ignoring unnecessary profile: 'ModuleA/client'
           Name +: +ModuleA
           Stream +: +f26 \[e\]
           Version +: +1
           Profiles +: +client \[i\], server, devel, minimal, default
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-0:1-1.modA.noarch
            +: +TestB-0:1-1.modA.noarch
            +: +TestC-0:1-1.modA.noarch
            +: +TestD-0:1-1.modA.noarch
           
           Name +: +ModuleA
           Stream +: +f26 \[e\]
           Version +: +2
           Profiles +: +client \[i\], server, devel, minimal, default
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-0:1-2.modA.noarch
            +: +TestB-0:1-1.modA.noarch
            +: +TestC-0:1-2.modA.noarch
            +: +TestD-0:1-1.modA.noarch
 
           Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled
           """

  # bz1540189
  Scenario: Non-existent profile is ignored for dnf module info
       When I run "dnf module info ModuleA:f26/non-existent-profile"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           Ignoring unnecessary profile: 'ModuleA/non-existent-profile'
           Name +: +ModuleA
           Stream +: +f26 \[e\]
           Version +: +1
           Profiles +: +client \[i\], server, devel, minimal, default
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-0:1-1.modA.noarch
            +: +TestB-0:1-1.modA.noarch
            +: +TestC-0:1-1.modA.noarch
            +: +TestD-0:1-1.modA.noarch
           
           Name +: +ModuleA
           Stream +: +f26 \[e\]
           Version +: +2
           Profiles +: +client \[i\], server, devel, minimal, default
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-0:1-2.modA.noarch
            +: +TestB-0:1-1.modA.noarch
            +: +TestC-0:1-2.modA.noarch
            +: +TestD-0:1-1.modA.noarch
 
           Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled
           """

  #bz 1623535
  Scenario: Get error message when info for non-existent module is requested
       When I run "dnf module info non-existent-module"
       Then the command should fail
        And the command stdout should match regexp "Unable to resolve argument non-existent-module"
        And the command stderr should match regexp "Error: No matching Modules to list"

  Scenario: Get info for two enabled modules from different repos
       When I successfully run "dnf module info ModuleA:f27 ModuleX"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           Name +: +ModuleA
           Stream +: +f27
           Version +: +1
           Profiles +: +client, server, devel, minimal, default
           Repo +: +modularityABDE
           Summary +: +Module ModuleA summary
           Description +: +Module ModuleA description
           Artifacts +: +TestA-0:2-1.modA.noarch
            +: +TestB-0:2-1.modA.noarch
            +: +TestC-0:2-1.modA.noarch
            +: +TestD-0:2-1.modA.noarch
         
           Name +: +ModuleX
           Stream +: +f26
           Version +: +1
           Profiles +: +default
           Repo +: +modularityX
           Summary +: +Module ModuleX summary
           Description +: +Module ModuleX description
           Artifacts +: +TestX-0:1-1.modX.noarch
           
           Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled
           """

  @xfail @bz1623535
  Scenario: Get info for two modules, one of them non-existent
       When I run "dnf module info non-existent-module ModuleX"
       Then the command should fail
        And the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           
           No such module: non-existent-module
           
           Name +: +ModuleX
           Stream +: +f26
           Version +: +1
           Profiles +: +default
           Repo +: +modularityX
           Summary +: +Module ModuleX summary
           Description +: +Module ModuleX description
           Artifacts +: +TestX-0:1-1.modX.noarch
           
           Hint: \[d\]efault, \[e\]nabled, \[x\]disabled, \[i\]nstalled
           """

  Scenario: Run 'dnf module info' without further argument
       When I run "dnf module info"
       Then the command should fail
        And the command stderr should match regexp "Error: dnf module info: too few arguments"
