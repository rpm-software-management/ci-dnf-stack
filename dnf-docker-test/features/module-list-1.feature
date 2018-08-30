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
           Name +Stream +Profiles +Summary
           ModuleA +f26 \[e\] +client\[i\], default, devel, minimal, s.* +Module +ModuleA sum
           ?^[^M]
           ModuleA +f27 +client, default, devel, minimal, server.*Module +ModuleA sum
           ?^[^M]
           ModuleB +f26 +default +Module +ModuleB sum
           ?^[^M]
           ModuleB +f27 +default +Module +ModuleB sum
           ?^[^M]
           ModuleD +f26 +default +Module +ModuleD sum
           ?^[^M]
           ModuleE +f26 +default +Module +ModuleE sum
           ?^[^M]

           modularityX
           ModuleA +f26 \[e\] +client\[i\], default, devel, minimal, ser.*Module +ModuleA sum
           ?^[^M]
           ModuleX +f26 \[e\] +default\[i\] +Module +ModuleX sum
           ?^[^M]

           Hint:
           """

  Scenario: I can list enabled modules
       When I successfully run "dnf module list --enabled"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Profiles +Summary
           ModuleA +f26 \[e\] +client\[i\], default, devel, minimal, ser.*Module +ModuleA sum
           ?^[^M]

           modularityX
           ModuleA +f26 \[e\] +client\[i\], default, devel, minimal, ser.*Module +ModuleA sum
           ?^[^M]
           ModuleX +f26 \[e\] +default\[i\] +Module +ModuleX sum
           ?^[^M]

           Hint:
           """

  Scenario: I can list installed modules
       When I successfully run "dnf module list --installed"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Profiles +Summary
           ModuleA +f26 \[e\] +client\[i\], default, devel, minimal, ser.*Module +ModuleA sum
           ?^[^M]

           modularityX
           ModuleA +f26 \[e\] +client\[i\], default, devel, minimal, ser.*Module +ModuleA sum
           ?^[^M]
           ModuleX +f26 \[e\] +default\[i\] +Module +ModuleX sum
           ?^[^M]

           Hint:
           """

  Scenario: I can list disabled modules
       When I successfully run "dnf module list --disabled"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Profiles +Summary
           ModuleA +f27 +client, default, devel, minimal, ser.*Module +ModuleA sum
           ?^[^M]
           ModuleB +f26 +default +Module +ModuleB sum
           ?^[^M]
           ModuleB +f27 +default +Module +ModuleB sum
           ?^[^M]
           ModuleD +f26 +default +Module +ModuleD sum
           ?^[^M]
           ModuleE +f26 +default +Module +ModuleE sum
           ?^[^M]

           Hint:
           """

  Scenario: I can limit the scope through providing specific module names
       When I successfully run "dnf module list ModuleA ModuleE ModuleX"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Profiles +Summary
           ModuleA +f26 \[e\] client\[i\], default, devel, minimal, ser.*Module +ModuleA sum
           ?^[^M]
           ModuleA +f27 +client, default, devel, minimal, ser.*Module +ModuleA sum
           ?^[^M]
           ModuleE +f26 +default +Module +ModuleE sum
           ?^[^M]

           modularityX
           ModuleA +f26 \[e\] client\[i\], default, devel, minimal, ser.*Module +ModuleA sum
           ?^[^M]
           ModuleX +f26 \[e\] default\[i\] +Module +ModuleX sum
           ?^[^M]

           Hint:
           """
       When I successfully run "dnf module list --installed ModuleX"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityX
           Name +Stream +Profiles +Summary
           ModuleX +f26 \[e\] +default\[i\] +Module +ModuleX summary

           Hint:
           """
       When I successfully run "dnf module list --enabled ModuleA"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Profiles +Summary
           ModuleA +f26 \[e\] +client\[i\], default, devel, minimal, ser.*Module +ModuleA sum
           ?^[^M]

           Hint:
           """
       When I successfully run "dnf module list --disabled ModuleB ModuleD"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Profiles +Summary
           ModuleB +f26 +default +Module +ModuleB summary
           ModuleB +f27 +default +Module +ModuleB summary
           ModuleD +f26 +default +Module +ModuleD summary

           Hint:
           """

  Scenario: Following module details are listed: Name, Stream, Profiles, Summary
       When I successfully run "dnf module list ModuleA ModuleE ModuleX"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Profiles +Summary
           ModuleA +f26 \[e\] +client\[i\], default, devel, minimal, ser.*Module +ModuleA sum
           ?^[^M]
           ModuleA +f27 +client, default, devel, minimal, ser.*Module +ModuleA sum
           ?^[^M]
           ModuleE +f26 +default +Module +ModuleE summ
           ?^[^M]

           modularityX
           ModuleA +f26 \[e\] +client\[i\], default, devel, minimal, ser.*Module +ModuleA sum
           ?^[^M]
           ModuleX +f26 \[e\] +default\[i\] +Module +ModuleX summ
           ?^[^M]

           Hint: \[d\]efault, \[e\]nabled, \[i\]nstalled
           """

  Scenario: I can see only modules' packages, not modules themselves in the output of 'dnf list'
       When I successfully run "dnf list"
       Then the command stdout should not match regexp "^Module"
       When I successfully run "dnf list Test\* Module\*"
       Then the command stdout section "Installed Packages" should match regexp "TestA.*1-2.modA"
        And the command stdout section "Installed Packages" should match regexp "TestB.*1-1.modA"
        And the command stdout section "Installed Packages" should match regexp "TestX.*1-1.modX"
        And the command stdout section "Available Packages" should match regexp "TestC.*1-2.modA"
        And the command stdout section "Available Packages" should match regexp "TestD.*1-1.modA"
        And the command stdout should not match regexp "^Module"
