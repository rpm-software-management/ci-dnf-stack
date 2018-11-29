Feature: Install a module of which all packages and requires are already installed

  @setup
  Scenario: Testing setup
      Given I run steps from file "modularity-repo-6.setup"
        And an INI file "/etc/yum.repos.d/modularityM.repo" modified with
         | Section     | Key             | Value     |
         | modularityM | module_hotfixes | True      |
       When I enable repository "modularityM"
        And I enable repository "ursineY"
        And I successfully run "dnf makecache"
        And I successfully run "dnf -y module enable ModuleM:f26"
        And I successfully run "dnf -y module enable ModuleMX:f26"

  @bz1566078
  Scenario: Install a module of which all packages and requires are already installed
       When I successfully run "dnf module list ModuleM"
       Then the command stdout should match regexp "ModuleM +f26 \[e\] +default +Module"
       # install ModuleM requires
       When I successfully run "dnf -y module install ModuleMX:f26/default"
       # install packages that are parts of ModuleM
        And I successfully run "dnf -y install TestMA TestMB TestMBX"
        And I save rpmdb
        And I successfully run "dnf -y module install ModuleM:f26/default"
       Then the command stdout should match regexp "Installing module profiles:"
        And the command stdout should match regexp "ModuleM/default"
        And the command stdout should not match regexp "Nothing to do"
        And a module "ModuleM" config file should contain
         | Key      | Value   |
         | profiles | default |
         | state    | enabled |
         | stream   | f26     |
        And rpmdb does not change
       When I successfully run "dnf module list ModuleM"
       Then the command stdout should match regexp "ModuleM +f26 \[e\] +default \[i\]"
