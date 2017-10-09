Feature: Module listing

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

  Scenario: I can list all available modules
       When I successfully run "dnf module list"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version
           ModuleA +f26 +1
           ModuleB +f26 +2
           ModuleD +f26 +1
           ModuleE +f26 +1

           modularityX
           Name +Stream +Version
           ModuleX +f26 +1
           """

  Scenario: I can list enabled modules
       When I successfully run "dnf module list --enabled"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version
           ModuleA +f26 +1

           modularityX
           Name +Stream +Version
           ModuleX +f26 +1
           """

  Scenario: I can list installed modules
       When I successfully run "dnf module list --installed"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version
           ModuleA +f26 +1

           modularityX
           Name +Stream +Version
           ModuleX +f26 +1
           """

  Scenario: I can list disabled modules
       When I successfully run "dnf module list --disabled"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version
           ModuleB +f26 +2
           ModuleD +f26 +1
           ModuleE +f26 +1
           """

  Scenario: I can limit the scope through providing specific module names
       When I successfully run "dnf module list ModuleA ModuleE ModuleX"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version
           ModuleA +f26 +1
           ModuleE +f26 +1

           modularityX
           Name +Stream +Version
           ModuleX +f26 +1
           """
       When I successfully run "dnf module list --installed ModuleX"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityX
           Name +Stream +Version
           ModuleX +f26 +1
           """
       When I successfully run "dnf module list --enabled ModuleA"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version
           ModuleA +f26 +1
           """
       When I successfully run "dnf module list --disabled ModuleB ModuleD"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version
           ModuleB +f26 +1
           ModuleD +f26 +1
           """

  Scenario: Following module details are listed: Name, Stream, Version, Profiles, Installed, Info
       When I successfully run "dnf module list ModuleA ModuleE ModuleX"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version +Profiles +Installed +Info
           ModuleA +f26 +1 +client, default, ... +client +Module ModuleA summary
           ModuleE +f26 +1 +default +Module ModuleE summary

           modularityX
           Name +Stream +Version +Profiles +Installed +Info
           ModuleX +f26 +1 +default +default +Module ModuleX summary
           """
