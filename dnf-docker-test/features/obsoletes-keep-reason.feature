Feature: DNF/Behave test Obsolete keep reason

    @setup
    Scenario: Feature Setup
        Given repository "test" with packages
           | Package | Tag       | Value |
           | TestB   |           |       |
          And repository "updates" with packages
           | Package | Tag       | Value |
           | TestA   | Obsoletes | TestB |
         When I save rpmdb
          And I enable repository "test"
          And I successfully run "dnf install -y TestB"
         Then rpmdb changes are
           | State     | Packages |
           | installed | TestB    |

    @xfail @bz1672618
    Scenario: Keep reason of obsolete package
         When I successfully run "dnf mark remove TestB"
         Then history userinstalled should
           | Action    | Packages |
           | Not match | TestB    |
         When I save rpmdb
          And I enable repository "updates"
          And I successfully run "dnf update -y"
         Then rpmdb changes are
           | State     | Packages |
           | installed | TestA    |
           | removed   | TestB    |
          And history userinstalled should
           | Action    | Packages |
           | Not match | TestA    |
