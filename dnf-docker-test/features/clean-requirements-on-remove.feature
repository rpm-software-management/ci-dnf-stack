Feature: Removal of package with clean_requirements_on_remove

  @setup
  Scenario: Feature Setup
      Given enabled repository "available" with packages
         | Package | Tag      | Value  |
         | TestA   | Requires | TestB  |
         | TestB   |          |        |

  Scenario: Remove with --setopt=clean_requirements_on_remove=True
       When I save rpmdb
        And I successfully run "dnf -y install TestA"
       Then rpmdb changes are
         | State     | Packages     |
         | installed | TestA, TestB |
       When I save rpmdb
        And I successfully run "dnf --setopt=clean_requirements_on_remove=True -y remove TestA"
       Then rpmdb changes are
         | State     | Packages     |
         | removed   | TestA, TestB |

  Scenario: Remove with --setopt=clean_requirements_on_remove=False
       When I save rpmdb
        And I successfully run "dnf -y install TestA"
       Then rpmdb changes are
         | State     | Packages     |
         | installed | TestA, TestB |
       When I save rpmdb
        And I successfully run "dnf --setopt=clean_requirements_on_remove=False -y remove TestA"
       Then rpmdb changes are
         | State     | Packages     |
         | removed   | TestA        |
         | unchanged | TestB        |
