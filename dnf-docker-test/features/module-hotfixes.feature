Feature: hotfix repo content is not masked by a modular content

  @setup
  Scenario: Testing repository setup
      Given I run steps from file "modularity-repo-2.setup"
        And repository "hotfix" with packages
          | Package | Tag     | Value |
          | TestX   | Version | 2     |
          |         | Release | 1     |
        And an INI file "/etc/yum.repos.d/hotfix.repo" modified with
          | Section | Key             | Value |
          | hotfix  | module_hotfixes | True  |
       When I enable repository "modularityX"
        And I enable repository "hotfix"
        And I run "dnf makecache"

  @bz1654738
  Scenario: hotfix content updates are used when installing a module stream
      Given I successfully run "dnf -y module enable ModuleX:f26"
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleX/default"
       Then a module "ModuleX" config file should contain
          | Key       | Value     |
          | state     | enabled   |
          | stream    | f26       |
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestX/2-1 |

  @setup @bz1654738
  Scenario: cleanup from previous scenario
       When I save rpmdb
        And I successfully run "dnf -y module remove ModuleX"
        And I successfully run "dnf -y module reset ModuleX"
        And I run "dnf -y remove TestX"
       Then rpmdb changes are
          | State   | Packages |
          | removed | TestX    |

  Scenario: hotfix content update is used when installing a package
      Given I successfully run "dnf -y module enable ModuleX:f26"
       When I save rpmdb
        And I successfully run "dnf -y install TestX"
       Then rpmdb changes are
          | State     | Packages  |
          | installed | TestX/2-1 |

  @setup
  Scenario: cleanup from previous scenario
       When I save rpmdb
        And I successfully run "dnf -y module remove ModuleX"
        And I successfully run "dnf -y module reset ModuleX"
        And I run "dnf -y remove TestX"
       Then rpmdb changes are
          | State   | Packages |
          | removed | TestX    |

  Scenario: hotfix content updates are used for updating a module
      Given I successfully run "dnf -y module enable ModuleX:f26"
       When I disable repository "hotfix"
        And I save rpmdb
        And I successfully run "dnf -y module install ModuleX/default"
       Then rpmdb changes are
          | State     | Packages       |
          | installed | TestX/1-1.modX |
       When I enable repository "hotfix"
        And I save rpmdb
        And I successfully run "dnf -y module update ModuleX"
       Then rpmdb changes are
          | State     | Packages       |
          | upgraded  | TestX/2-1      |

  @setup
  Scenario: cleanup from previous scenario
       When I save rpmdb
        And I successfully run "dnf -y module remove ModuleX"
        And I successfully run "dnf -y module reset ModuleX"
        And I run "dnf -y remove TestX"
       Then rpmdb changes are
          | State   | Packages |
          | removed | TestX    |

  Scenario: hotfix content is used when listing available updates
      Given I successfully run "dnf -y module enable ModuleX:f26"
       When I disable repository "hotfix"
        And I save rpmdb
        And I successfully run "dnf -y module install ModuleX/default"
       Then rpmdb changes are
          | State     | Packages       |
          | installed | TestX/1-1.modX |
       When I enable repository "hotfix"
        And I run "dnf makecache"
        And I run "dnf check-update"
       Then the command stdout should match line by line regexp
          """
          ?Last metadata
          ?$
          ^TestX\.noarch +2-1 +hotfix$
          """

  Scenario: hotfix content updates are used for updating a system
       When I save rpmdb
        And I successfully run "dnf -y upgrade"
       Then rpmdb changes are
          | State    | Packages  |
          | upgraded | TestX/2-1 |
