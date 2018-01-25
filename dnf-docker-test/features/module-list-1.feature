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
           ModuleA +f26 \[e\] +2
           ModuleA +f27 +1
           ModuleB +f26 +2
           ModuleB +f27 +1
           ModuleD +f26 +1
           ModuleE +f26 +1

           modularityX
           Name +Stream +Version
           ModuleX +f26 \[e\] +1

           Hint:
           """

  Scenario: I can list enabled modules
       When I successfully run "dnf module list --enabled"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version
           ModuleA +f26 \[e\] +1
           ModuleA +f26 \[e\] +2

           modularityX
           Name +Stream +Version
           ModuleX +f26 \[e\] +1

           Hint:
           """

  Scenario: I can list installed modules
       When I successfully run "dnf module list --installed"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version
           ModuleA +f26 \[e\] +2

           modularityX
           Name +Stream +Version
           ModuleX +f26 \[e\] +1

           Hint:
           """

  Scenario: I can list disabled modules
       When I successfully run "dnf module list --disabled"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version
           ModuleA +f27 +1
           ModuleB +f26 +1
           ModuleB +f26 +2
           ModuleB +f27 +1
           ModuleD +f26 +1
           ModuleE +f26 +1

           Hint:
           """

  Scenario: I can limit the scope through providing specific module names
       When I successfully run "dnf module list ModuleA ModuleE ModuleX"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version
           ModuleA +f26 \[e\] +2
           ModuleA +f27 +1
           ModuleE +f26 +1

           modularityX
           Name +Stream +Version
           ModuleX +f26 \[e\] +1

           Hint:
           """
       When I successfully run "dnf module list --installed ModuleX"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityX
           Name +Stream +Version
           ModuleX +f26 \[e\] +1

           Hint:
           """
       When I successfully run "dnf module list --enabled ModuleA"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version
           ModuleA +f26 \[e\] +1
           ModuleA +f26 \[e\] +2

           Hint:
           """
       When I successfully run "dnf module list --disabled ModuleB ModuleD"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version
           ModuleB +f26 +1
           ModuleB +f26 +2
           ModuleB +f27 +1
           ModuleD +f26 +1

           Hint:
           """

  Scenario: Following module details are listed: Name, Stream, Version, Profiles, Installed, Info
       When I successfully run "dnf module list ModuleA ModuleE ModuleX"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version +Profiles +
           ModuleA +f26 \[e\] +2 +client \[i\], default, ...
           ModuleA +f27 +1 +client, default, ...
           ModuleE +f26 +1 +default

           modularityX
           Name +Stream +Version +Profiles +
           ModuleX +f26 \[e\] +1 +default \[i\]

           Hint: \[d\]efault, \[e\]nabled, \[i\]nstalled, \[l\]ocked
           """

  Scenario: I can see locked modules in the output of 'dnf module list'
       When I successfully run "dnf module enable ModuleE:f26"
        And I successfully run "dnf module lock ModuleE:f26"
        And I successfully run "dnf module lock ModuleA/client"
        And I successfully run "dnf module list ModuleA ModuleE"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version +Profiles +
           ModuleA +f26 \[e\] +2 \[l\] +client \[i\], default, ...
           ModuleA +f27 +1 +client, default, ...
           ModuleE +f26 \[e\] +1 \[l\] +default

           Hint: \[d\]efault, \[e\]nabled, \[i\]nstalled, \[l\]ocked
           """
       When I successfully run "dnf module unlock ModuleA"
        And I successfully run "dnf module list ModuleA ModuleE"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version +Profiles +
           ModuleA +f26 \[e\] +2 +client \[i\], default, ...
           ModuleA +f27 +1 +client, default, ...
           ModuleE +f26 \[e\] +1 \[l\] +default

           Hint: \[d\]efault, \[e\]nabled, \[i\]nstalled, \[l\]ocked
           """
       When I successfully run "dnf module lock ModuleX"
        And I successfully run "dnf module list Module[EX]"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Version +Profiles +
           ModuleE +f26 \[e\] +1 \[l\] +default

           modularityX
           Name +Stream +Version +Profiles +
           ModuleX +f26 \[e\] +1 \[l\] +default \[i\]

           Hint: \[d\]efault, \[e\]nabled, \[i\]nstalled, \[l\]ocked
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
        And the command stdout section "Available Packages" should match regexp "TestP.*1-1.modE"
        And the command stdout should not match regexp "^Module"
