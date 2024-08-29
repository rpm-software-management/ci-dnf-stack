@dnf5
@dnf5daemon
Feature: Tests for group list and info commands

Background: Enable repo and mark a group as installed
 Given I use repository "comps-group-list"
 Given I create file "/usr/lib/sysimage/libdnf5/groups.toml" with
    """
    version = "1.0"

    [groups]

    [groups.test-group]
    userinstalled = true
    """

Scenario: All user visible groups are listed by default (installed group is not duplicated)
  When I execute dnf with args "group list"
  Then the exit code is 0
   And stderr is
       """
       <REPOSYNC>
       """
   And stdout is
       """
       ID                   Name        Installed
       empty-group          Empty group        no
       no-name-group                           no
       test-group           Test Group        yes 
       """

Scenario: I can list also hidden groups
  When I execute dnf with args "group list --hidden"
  Then the exit code is 0
   And stderr is
       """
       <REPOSYNC>
       """
   And stdout is
       """
       ID                   Name         Installed
       empty-group          Empty group         no
       hidden-group         Hidden group        no
       no-name-group                            no
       test-group           Test Group         yes
       """

Scenario: I can filter listed groups by their ids (hidden groups are included)
  When I execute dnf with args "group list "hidden-*""
  Then the exit code is 0
   And stderr is
       """
       <REPOSYNC>
       """
   And stdout is
       """
       ID                   Name         Installed
       hidden-group         Hidden group        no
       """

Scenario: I can filter listed groups by their names (hidden groups are included)
  When I execute dnf with args "group list "* group""
  Then the exit code is 0
   And stderr is
       """
       <REPOSYNC>
       """
   And stdout is
       """
       ID                   Name         Installed
       empty-group          Empty group         no
       hidden-group         Hidden group        no
       test-group           Test Group         yes
       """

Scenario: I can list only installed groups
  When I execute dnf with args "group list --installed"
  Then the exit code is 0
   And stderr is
       """
       <REPOSYNC>
       """
   And stdout is
       """
       ID                   Name       Installed
       test-group           Test Group       yes 
       """

Scenario: I can list only available groups
  When I execute dnf with args "group list --available"
  Then the exit code is 0
   And stderr is
       """
       <REPOSYNC>
       """
   And stdout is
       """
       ID                   Name        Installed
       empty-group          Empty group        no
       no-name-group                           no
       test-group           Test Group         no
       """

Scenario: I can list only groups containing a package
  When I execute dnf with args "group list --contains-pkgs=test-package"
  Then the exit code is 0
   And stderr is
       """
       <REPOSYNC>
       """
   And stdout is
       """
       ID                   Name       Installed
       no-name-group                          no
       test-group           Test Group       yes
       """

Scenario: I can get info about all groups (installed group is not duplicated)
  When I execute dnf with args "group info"
  Then the exit code is 0
   And stderr is
      """
      <REPOSYNC>
      """
   And stdout is
      """
      Id                   : empty-group
      Name                 : Empty group
      Description          : 
      Installed            : no
      Order                : 
      Langonly             : 
      Uservisible          : yes
      Repositories         : comps-group-list
      
      Id                   : test-group
      Name                 : Test Group
      Description          : Test Group description.
      Installed            : yes
      Order                : 
      Langonly             : 
      Uservisible          : yes
      Repositories         : @System
      Mandatory packages   : test-package
      
      Id                   : no-name-group
      Name                 : 
      Description          : 
      Installed            : no
      Order                : 
      Langonly             : 
      Uservisible          : yes
      Repositories         : comps-group-list
      Mandatory packages   : test-package
      """


Scenario Outline: Info command accepts <option> option
  When I execute dnf with args "group info <option>"
  Then the exit code is 0

Examples:
    | option                |
    | --hidden              |
    | --installed           |
    | --available           |
    | --contains-pkgs=pkg   |
