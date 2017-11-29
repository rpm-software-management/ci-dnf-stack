Feature: Test for repository priorities

  @setup
  Scenario: Preparing the test repositories
      Given repository "repo10" with packages
         | Package      | Tag       | Value        |
         | TestA        | Version   | 2            |
         | TestB        | Version   | 1            |
         |              | Requires  | TestC        |
         | TestD        | Version   | 1            |
      And repository "repo20" with packages
         | Package      | Tag       | Value        |
         | TestA        | Version   | 1            |
         | TestB        | Version   | 2            |
         |              | Requires  | TestC        |
         | TestC        | Version   | 2            |
         |              | Requires  | TestD        |
      And repository "repo30" with packages
         | Package      | Tag       | Value        |
         | TestA        | Version   | 3            |
         | TestB        | Version   | 3            |
         |              | Requires  | TestC        |
         | TestC        | Version   | 3            |
         |              | Requires  | TestD        |
         | TestD        | Version   | 3            |
         | TestE        | Version   | 3            |
      And an INI file "/etc/yum.repos.d/repo10.repo" modified with
         | Section | Key        | Value |
         | repo10  | priority   | 10    |
      And an INI file "/etc/yum.repos.d/repo20.repo" modified with
         | Section | Key        | Value |
         | repo20  | priority   | 20    |
      And an INI file "/etc/yum.repos.d/repo30.repo" modified with
         | Section | Key        | Value |
         | repo30  | priority   | 30    |

  Scenario: Install a single pkg from the highest prio repo
       When I save rpmdb
        And I enable repository "repo10"
        And I enable repository "repo20"
        And I enable repository "repo30"
        And I run "dnf -y install TestA"
       Then rpmdb changes are
         | State     | Packages           |
         | installed | TestA/2            |

  Scenario: Install required version of a pkg (not from the highest prio repo)
       When I run "dnf -y remove TestA"
        And I save rpmdb
        And I run "dnf -y install TestA-3"
       Then rpmdb changes are
         | State     | Packages           |
         | installed | TestA/3            |

  Scenario: Install wildcard-specified pkgs from different highest prio repos
     When I save rpmdb
      And I run "dnf -y install Test[DE]*"
     Then rpmdb changes are
       | State     | Packages           |
       | installed | TestD/1,TestE/3    |

  Scenario: Install a pkg and its deps from the proper highest prio repos
       When I run "dnf -y remove TestD"
        And I save rpmdb
        And I run "dnf -y install TestB"
       Then rpmdb changes are
         | State     | Packages                |
         | installed | TestB/1,TestC/2,TestD/1 |

  Scenario: Upgrade a single pkg from the highest prio repo
       When I run "dnf -y downgrade TestA-1"
        And I save rpmdb
        And I run "dnf -y upgrade TestA"
       Then rpmdb changes are
         | State     | Packages           |
         | updated   | TestA/2            |

  Scenario: Upgrade to required version of a pkg (not from the highest prio repo)
       When I save rpmdb
        And I run "dnf -y upgrade TestB-3"
       Then rpmdb changes are
         | State     | Packages           |
         | updated   | TestB/3            |

  Scenario: Upgrade wildcard-specified pkgs from different highest prio repos
       When I run "dnf -y downgrade Test[ABD]-1"
        And I disable repository "repo10"
        And I save rpmdb
        And I run "dnf -y upgrade Test*"
       Then rpmdb changes are
         | State     | Packages           |
         | updated   | TestB/2,TestD/3    |

  Scenario: Downgrade a single pkg from the highest prio repo
       When I enable repository "repo10"
        And I run "dnf -y upgrade TestB-3"
        And I save rpmdb
        And I run "dnf -y downgrade TestB"
       Then rpmdb changes are
         | State      | Packages           |
         | downgraded | TestB/1            |

  Scenario: Downgrade to required version of a pkg (not from the highest prio repo)
       When I run "dnf -y upgrade TestA-3"
        And I save rpmdb
        And I run "dnf -y downgrade TestA-1"
       Then rpmdb changes are
         | State      | Packages           |
         | downgraded | TestA/1            |

  Scenario: Downgrade wildcard-specified pkgs from different highest prio repos
       When I run "dnf -y upgrade Test[ABCD]-3"
        And I save rpmdb
        And I run "dnf -y downgrade Test*"
       Then rpmdb changes are
         | State      | Packages           |
         | downgraded | TestA/2,TestB/1,TestC/2,TestD/1 |
