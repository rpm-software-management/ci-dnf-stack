Feature: Test the security filters for offline-upgrade commands


Background:
  Given I enable plugin "system-upgrade"
    And I use repository "dnf-ci-fedora"


@bz1939975
Scenario: Test advisory filter with offline-upgrade
Given I execute dnf with args "install glibc flac"
 Then the exit code is 0
Given I use repository "dnf-ci-fedora-updates"
 When I execute dnf with args "offline-upgrade download"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package               Arch     Version           Repository               Size
      ================================================================================
      Upgrading:
       flac                  x86_64   1.3.3-3.fc29      dnf-ci-fedora-updates   6.4 k
       glibc                 x86_64   2.28-26.fc29      dnf-ci-fedora-updates    11 k
       glibc-all-langpacks   x86_64   2.28-26.fc29      dnf-ci-fedora-updates   6.3 k
       glibc-common          x86_64   2.28-26.fc29      dnf-ci-fedora-updates   6.4 k
      
      Transaction Summary
      ================================================================================
      Upgrade  4 Packages
      """
 When I execute dnf with args "offline-upgrade download --advisory FEDORA-2018-318f184000"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package               Arch     Version           Repository               Size
      ================================================================================
      Upgrading:
       glibc                 x86_64   2.28-26.fc29      dnf-ci-fedora-updates    11 k
       glibc-all-langpacks   x86_64   2.28-26.fc29      dnf-ci-fedora-updates   6.3 k
       glibc-common          x86_64   2.28-26.fc29      dnf-ci-fedora-updates   6.4 k
      
      Transaction Summary
      ================================================================================
      Upgrade  3 Packages
      """


@bz1939975
Scenario: Test bugfix filter with offline-upgrade
Given I use repository "dnf-ci-fedora-updates"
  And I execute dnf with args "install flac-1.3.2 kernel-4.18.16"
 Then the exit code is 0
 When I execute dnf with args "offline-upgrade download"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package           Arch      Version             Repository                Size
      ================================================================================
      Installing:
       kernel            x86_64    4.19.15-300.fc29    dnf-ci-fedora-updates    6.2 k
      Upgrading:
       flac              x86_64    1.3.3-3.fc29        dnf-ci-fedora-updates    6.4 k
      Installing dependencies:
       kernel-core       x86_64    4.19.15-300.fc29    dnf-ci-fedora-updates     51 k
       kernel-modules    x86_64    4.19.15-300.fc29    dnf-ci-fedora-updates     47 k
      
      Transaction Summary
      ================================================================================
      Install  3 Packages
      Upgrade  1 Package

      """
 When I execute dnf with args "offline-upgrade download --bugfix"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package           Arch      Version             Repository                Size
      ================================================================================
      Installing:
       kernel            x86_64    4.19.15-300.fc29    dnf-ci-fedora-updates    6.2 k
      Installing dependencies:
       kernel-core       x86_64    4.19.15-300.fc29    dnf-ci-fedora-updates     51 k
       kernel-modules    x86_64    4.19.15-300.fc29    dnf-ci-fedora-updates     47 k
      
      Transaction Summary
      ================================================================================
      Install  3 Packages
      """


@bz1939975
Scenario: Test bz filter with offline-upgrade
Given I execute dnf with args "install glibc flac"
 Then the exit code is 0
Given I use repository "dnf-ci-fedora-updates"
 When I execute dnf with args "offline-upgrade download"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package               Arch     Version           Repository               Size
      ================================================================================
      Upgrading:
       flac                  x86_64   1.3.3-3.fc29      dnf-ci-fedora-updates   6.4 k
       glibc                 x86_64   2.28-26.fc29      dnf-ci-fedora-updates    11 k
       glibc-all-langpacks   x86_64   2.28-26.fc29      dnf-ci-fedora-updates   6.3 k
       glibc-common          x86_64   2.28-26.fc29      dnf-ci-fedora-updates   6.4 k
      
      Transaction Summary
      ================================================================================
      Upgrade  4 Packages
      """
 When I execute dnf with args "offline-upgrade download --bz=222"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package               Arch     Version           Repository               Size
      ================================================================================
      Upgrading:
       glibc                 x86_64   2.28-26.fc29      dnf-ci-fedora-updates    11 k
       glibc-all-langpacks   x86_64   2.28-26.fc29      dnf-ci-fedora-updates   6.3 k
       glibc-common          x86_64   2.28-26.fc29      dnf-ci-fedora-updates   6.4 k
      
      Transaction Summary
      ================================================================================
      Upgrade  3 Packages
      """


@bz1939975
Scenario: Test cve filter with offline-upgrade
Given I execute dnf with args "install glibc flac"
 Then the exit code is 0
Given I use repository "dnf-ci-fedora-updates"
 When I execute dnf with args "offline-upgrade download"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package               Arch     Version           Repository               Size
      ================================================================================
      Upgrading:
       flac                  x86_64   1.3.3-3.fc29      dnf-ci-fedora-updates   6.4 k
       glibc                 x86_64   2.28-26.fc29      dnf-ci-fedora-updates    11 k
       glibc-all-langpacks   x86_64   2.28-26.fc29      dnf-ci-fedora-updates   6.3 k
       glibc-common          x86_64   2.28-26.fc29      dnf-ci-fedora-updates   6.4 k
      
      Transaction Summary
      ================================================================================
      Upgrade  4 Packages
      """
 When I execute dnf with args "offline-upgrade download --cve=CVE-2999"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package               Arch     Version           Repository               Size
      ================================================================================
      Upgrading:
       glibc                 x86_64   2.28-26.fc29      dnf-ci-fedora-updates    11 k
       glibc-all-langpacks   x86_64   2.28-26.fc29      dnf-ci-fedora-updates   6.3 k
       glibc-common          x86_64   2.28-26.fc29      dnf-ci-fedora-updates   6.4 k
      
      Transaction Summary
      ================================================================================
      Upgrade  3 Packages
      """


@bz1939975
Scenario: Test enhancement filter with offline-upgrade
Given I use repository "dnf-ci-fedora-updates"
  And I use repository "enhancement-test"
  And I execute dnf with args "install flac-1.3.2 kernel-4.18.16"
 Then the exit code is 0
 When I execute dnf with args "offline-upgrade download"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package           Arch      Version             Repository                Size
      ================================================================================
      Installing:
       kernel            x86_64    4.19.15-300.fc29    dnf-ci-fedora-updates    6.2 k
      Upgrading:
       flac              x86_64    1.3.9-1.fc29        enhancement-test         6.4 k
      Installing dependencies:
       kernel-core       x86_64    4.19.15-300.fc29    dnf-ci-fedora-updates     51 k
       kernel-modules    x86_64    4.19.15-300.fc29    dnf-ci-fedora-updates     47 k
      
      Transaction Summary
      ================================================================================
      Install  3 Packages
      Upgrade  1 Package

      """
 When I execute dnf with args "offline-upgrade download --enhancement"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package     Architecture  Version                Repository               Size
      ================================================================================
      Upgrading:
       flac        x86_64        1.3.9-1.fc29           enhancement-test        6.4 k
      
      Transaction Summary
      ================================================================================
      Upgrade  1 Package
      """


@bz1939975
Scenario: Test newpackage filter with offline-upgrade
Given I use repository "dnf-ci-fedora-updates"
  And I use repository "newpackage-test"
  And I execute dnf with args "install flac-1.3.2 somepackage-1.0"
 Then the exit code is 0
 When I execute dnf with args "offline-upgrade download"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package         Arch       Version             Repository                 Size
      ================================================================================
      Upgrading:
       flac            x86_64     1.3.3-3.fc29        dnf-ci-fedora-updates     6.4 k
       somepackage     x86_64     1.1-1               newpackage-test           6.0 k
      
      Transaction Summary
      ================================================================================
      Upgrade  2 Packages
      """
 When I execute dnf with args "offline-upgrade download --newpackage"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package             Architecture   Version       Repository               Size
      ================================================================================
      Upgrading:
       somepackage         x86_64         1.1-1         newpackage-test         6.0 k
      
      Transaction Summary
      ================================================================================
      Upgrade  1 Package
      """


@bz1939975
Scenario: Test security filter with offline-upgrade
Given I use repository "security-upgrade"
  And I execute dnf with args "install dracut-1-1 B-1-1"
 Then the exit code is 0
 When I execute dnf with args "offline-upgrade download"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package         Architecture    Version        Repository                 Size
      ================================================================================
      Upgrading:
       B               x86_64          2-2            security-upgrade          6.0 k
       dracut          x86_64          2-2            security-upgrade          6.0 k
      
      Transaction Summary
      ================================================================================
      Upgrade  2 Packages
      """
 When I execute dnf with args "offline-upgrade download --security"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package     Architecture     Version          Repository                  Size
      ================================================================================
      Upgrading:
       B           x86_64           2-2              security-upgrade           6.0 k
      
      Transaction Summary
      ================================================================================
      Upgrade  1 Package
      """


@bz1939975
Scenario: Test security severity filter with offline-upgrade
Given I use repository "dnf-ci-security"
  And I execute dnf with args "install bugfix_B-1.0-1 advisory_B-1.0-3 security_A-1.0-1"
 Then the exit code is 0
 When I execute dnf with args "offline-upgrade download"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package            Architecture   Version        Repository               Size
      ================================================================================
      Upgrading:
       advisory_B         x86_64         1.0-4          dnf-ci-security         6.0 k
       bugfix_B           x86_64         1.0-2          dnf-ci-security         6.0 k
       security_A         x86_64         1.0-4          dnf-ci-security         6.0 k
      
      Transaction Summary
      ================================================================================
      Upgrade  3 Packages
      """
 When I execute dnf with args "offline-upgrade download --secseverity=Critical"
 Then the exit code is 0
  And stdout contains lines
      """
      Dependencies resolved.
      ================================================================================
       Package            Architecture   Version        Repository               Size
      ================================================================================
      Upgrading:
       advisory_B         x86_64         1.0-4          dnf-ci-security         6.0 k
      
      Transaction Summary
      ================================================================================
      Upgrade  1 Package
      """

