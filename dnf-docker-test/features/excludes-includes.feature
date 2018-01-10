Feature: Test for dnf options includepkgs, excludepkgs, exclude, --disableexcludes, --disableexcludepkgs
 repo base: TestA-1 TestB-1 XTest-1
 repo ext: XTest-2 TestA-2 TestB-2

  @setup
  Scenario: Setup (create test repos)
      Given repository "base" with packages
         | Package      | Tag      | Value     |
         | XTest        | Version  | 1         |
         | TestA        | Version  | 1         |
         | TestB        | Version  | 1         |
        And repository "ext" with packages
         | Package      | Tag      | Value     |
         | XTest        | Version  | 2         |
         | TestA        | Version  | 2         |
         | TestB        | Version  | 2         |

  Scenario: install according to includepkgs in dnf.conf (there are matching pkgs)
       Given an INI file "/etc/dnf/dnf.conf" modified with
         | Section | Key           | Value     |
         | main    | includepkgs   | Test*     |
       When I enable repository "base"
        And I save rpmdb
        And I successfully run "dnf -y install \*Test\*"
       Then rpmdb changes are
         | State     | Packages           |
         | installed | TestA/1, TestB/1   |
        # cleanup of installed pkgs
        And I successfully run "dnf -y remove Test\*"

  Scenario: install according to includepkgs in dnf.conf (no matching pkgs)
       When I save rpmdb
        And I run "dnf -y install XT\*"
       Then the command should fail
        And rpmdb does not change

  Scenario: install according to includepkgs in .repo (there are matching pkgs)
       Given an INI file "/etc/dnf/dnf.conf" modified with
         | Section | Key           | Value     |
         | main    | -includepkgs  |           |
         And an INI file "/etc/yum.repos.d/base.repo" modified with
         | Section | Key           | Value     |
         | base    | includepkgs   | XTest*    |
       When I save rpmdb
        And I successfully run "dnf -y install \*Test\*"
       Then rpmdb changes are
         | State     | Packages  |
         | installed | XTest/1   |
        # cleanup of installed pkgs
        And I successfully run "dnf -y remove XTest\*"

  Scenario: install according to includepkgs in .repo (no matching pkgs)
       When I save rpmdb
        And I run "dnf -y install Test\*"
       Then the command should fail
        And rpmdb does not change

  Scenario: install according to includepkgs and excludepkgs in .repo
       Given an INI file "/etc/yum.repos.d/base.repo" modified with
         | Section | Key           | Value     |
         | base    | includepkgs   | Test*,XT* |
         | base    | excludepkgs   | TestA     |
       When I save rpmdb
        And I successfully run "dnf -y install \*Test\*"
       Then rpmdb changes are
         | State     | Packages  |
         | installed | TestB, XTest   |

  Scenario: upgrade according to includepkgs and exclude in dnf.conf
       Given an INI file "/etc/dnf/dnf.conf" modified with
         | Section | Key           | Value     |
         | main    | includepkgs   | *Test*    |
         |         | exclude       | TestB     |
       When I enable repository "ext"
        And I save rpmdb
        And I successfully run "dnf -y upgrade \*Test\*"
       Then rpmdb changes are
         | State     | Packages  |
         | upgraded  | XTest     |

  Scenario: excludes and includes combined with --disableexcludes or --disableexcludepkgs
       When I save rpmdb
        And I disable repository "ext"
        And I successfully run "dnf -y --disableexcludes=base install \*Test\*"
       Then rpmdb changes are
         | State     | Packages  |
         | installed | TestA/1   |
       When I save rpmdb
        And I enable repository "ext"
        And I successfully run "dnf -y --disableexcludepkgs=main upgrade \*Test\*"
       Then rpmdb changes are
         | State     | Packages  |
         | upgraded  | TestA/2, TestB/2 |

  Scenario: downgrade according to includes and excludes both in dnf.conf and .repo
       When I save rpmdb
        And I successfully run "dnf -y downgrade \*Test\*"
       Then rpmdb changes are
         | State      | Packages  |
         | downgraded | XTest/1   |

  Scenario: downgrade according to includes and excludes combined with --disableexcludes
       When I save rpmdb
        And I successfully run "dnf -y --disableexcludepkgs=all downgrade \*Test\*"
       Then rpmdb changes are
         | State      | Packages  |
         | downgraded | TestA/1, TestB/1 |
