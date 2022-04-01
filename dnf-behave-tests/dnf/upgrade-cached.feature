Feature: Upgrade packages already downloaded to the cache

Background: Install some RPMs from one repository
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install wget"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | wget-0:1.19.5-5.fc29.x86_64               |

@bz2024527
@bz2070966
@bz2070967
Scenario: Upgrade works correctly with non-english locale when packages were already downloaded to the cache
  Given I use repository "dnf-ci-fedora-updates" as http
    # pre-download updates to the cache
    And I successfully execute dnf with args "upgrade --downloadonly"
    And I set LC_ALL to "de_DE.utf-8"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And stdout contains "\[SKIPPED\] wget-1\.19\.6-5\.fc29\.x86_64\.rpm: Already downloaded"
    # cannot do `And Transaction is following` because changed locales break transaction table parsing
    And RPMDB Transaction is following
        | Action        | Package                                   |
        | upgrade       | wget-0:1.19.6-5.fc29.x86_64               |
