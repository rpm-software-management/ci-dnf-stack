Feature: Transaction history undo with obsoletes

# Package glibc-all-langpacks requires glibc
# Package glibc obsoletes glibc-profile < 2.4

Scenario: Undo with obsoletes
  Given I use the repository "dnf-ci-thirdparty"

   When I execute dnf with args "install glibc-profile"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | glibc-profile-0:2.3.1-10.x86_64           |

   When I enable the repository "dnf-ci-fedora"
    And I execute dnf with args "install glibc-all-langpacks"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install       | glibc-common-0:2.28-9.fc29.x86_64         |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | remove        | glibc-profile-0:2.3.1-10.x86_64           |

   When I execute dnf with args "history undo last"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | remove        | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
        | remove        | setup-0:2.12.1-1.fc29.noarch              |
        | remove        | glibc-0:2.28-9.fc29.x86_64                |
        | remove        | glibc-common-0:2.28-9.fc29.x86_64         |
        | remove        | filesystem-0:3.9-2.fc29.x86_64            |
        | remove        | basesystem-0:11-6.fc29.noarch             |
        | install       | glibc-profile-0:2.3.1-10.x86_64           |
        
