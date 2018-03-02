Feature: DNF/Behave test Repository packages info

    @setup
    Scenario: Feature setup
        Given repository "test" with packages
           | Package | Tag      | Value |
           | TestA   |          |       |
           | TestB   |          |       |
         When I save rpmdb
          And I enable repository "test"
          And I successfully run "dnf install -y TestA"
         Then rpmdb changes are
           | State     | Packages |
           | installed | TestA    |

    Scenario: List info of all packages in repository test
         When I successfully run "dnf -q repository-packages test info all"
         Then the command stdout should match
              """
              Installed Packages
              Name         : TestA
              Version      : 1
              Release      : 1
              Arch         : noarch
              Size         : 0.0
              Source       : TestA-1-1.src.rpm
              Repo         : @System
              From repo    : test
              Summary      : Empty
              License      : Public Domain
              Description  : Empty.

              Available Packages
              Name         : TestB
              Version      : 1
              Release      : 1
              Arch         : noarch
              Size         : 6.1 k
              Source       : TestB-1-1.src.rpm
              Repo         : test
              Summary      : Empty
              License      : Public Domain
              Description  : Empty.
              """

    Scenario: List all installed packages from repository
         When I successfully run "dnf -q repository-packages test info installed"
         Then the command stdout should match
              """
              Installed Packages
              Name         : TestA
              Version      : 1
              Release      : 1
              Arch         : noarch
              Size         : 0.0
              Source       : TestA-1-1.src.rpm
              Repo         : @System
              From repo    : test
              Summary      : Empty
              License      : Public Domain
              Description  : Empty.
              """

    Scenario: Single repository package info
         When I successfully run "dnf -q repository-packages test info TestB"
         Then the command stdout should match
              """
              Available Packages
              Name         : TestB
              Version      : 1
              Release      : 1
              Arch         : noarch
              Size         : 6.1 k
              Source       : TestB-1-1.src.rpm
              Repo         : test
              Summary      : Empty
              License      : Public Domain
              Description  : Empty.
              """

    Scenario: List repo extras - installed from repo, but not available anymore
         When I remove all repositories
        Given repository "test" with packages
           | Package | Tag      | Value |
           | TestB   |          |       |
         When I successfully run "dnf -q repository-packages test info extras"
         Then the command stdout should match
              """
              Extra Packages
              Name         : TestA
              Version      : 1
              Release      : 1
              Arch         : noarch
              Size         : 0.0
              Source       : TestA-1-1.src.rpm
              Repo         : @System
              From repo    : test
              Summary      : Empty
              License      : Public Domain
              Description  : Empty.
              """
