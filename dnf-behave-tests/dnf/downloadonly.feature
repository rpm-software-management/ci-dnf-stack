Feature: Only download rpms with --downloadonly and store them in cache

Scenario: Install/upgrade work correctly with --downloadonly argument
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install --downloadonly wget"
   Then the exit code is 0


   When I execute dnf with args "install wget"
   Then the exit code is 0
    And stdout contains "Need to download 0 B."
    And RPMDB Transaction is following
        | Action        | Package                                   |
        | install       | wget-0:1.19.5-5.fc29.x86_64               |

  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade --downloadonly wget"
   Then the exit code is 0

   When I execute rpm with args "-q wget"
   Then stdout contains "wget-1.19.5-5.fc29.x86_64"

   When I execute dnf with args "upgrade wget"
   Then the exit code is 0
    And stdout contains "Need to download 0 B."
    And RPMDB Transaction is following
        | Action        | Package                                   |
        | upgrade       | wget-0:1.19.6-5.fc29.x86_64               |

                             
