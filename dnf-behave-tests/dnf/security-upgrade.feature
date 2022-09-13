Feature: --security upgrades


@bz2088149
# More details in: https://github.com/rpm-software-management/libdnf/pull/1526
Scenario: --security upgrade with advisories with pkgs of different arches
Given I use repository "security-upgrade"
  And I execute dnf with args "install json-c-1-1 bind-libs-lite-1-1"
 When I execute dnf with args "upgrade --security"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                     |
      | upgrade       | bind-libs-lite-0:2-2.x86_64 |
      | upgrade       | json-c-0:2-2.x86_64         |


@bz2124483
# This scenario is the same as the one above just with noarch packages present in the
# repo and advisory instead of i686 this causes different behavior - it fails.
# Technically we could get bz2088149 again with just a different package set.
# However while this is possible it shouldn't happen because noarch packages are special - they work
# on all architectures and we shouldn't see noarch builds together with arch specific builds as it
# is setup in this scenario (in repo security-upgrade-noarch).
# More details in: https://github.com/rpm-software-management/libdnf/pull/1526
Scenario: --security upgrade with advisories with pkgs of different arches (noarch variant)
Given I use repository "security-upgrade-noarch"
  And I successfully execute dnf with args "install json-c-1-1 bind-libs-lite-1-1"
 Then Transaction is following
      | Action        | Package                     |
      | install       | bind-libs-lite-0:1-1.x86_64 |
      | install       | json-c-0:1-1.x86_64         |
 When I execute dnf with args "upgrade --security"
 Then the exit code is 1
 And dnf4 stderr is
 """
 Error: 
  Problem: cannot install both json-c-2-2.x86_64 and json-c-2-2.noarch
   - package bind-libs-lite-2-2.x86_64 requires libjson-c.so.4()(64bit), but none of the providers can be installed
   - cannot install the best update candidate for package json-c-1-1.x86_64
   - cannot install the best update candidate for package bind-libs-lite-1-1.x86_64
 """
 And dnf5 stderr is
 """
 Failed to resolve the transaction:
 Problem: cannot install both json-c-2-2.noarch and json-c-2-2.x86_64
   - package bind-libs-lite-2-2.x86_64 requires libjson-c.so.4()(64bit), but none of the providers can be installed
   - cannot install the best update candidate for package json-c-1-1.x86_64
   - cannot install the best update candidate for package bind-libs-lite-1-1.x86_64
 """


@2097757
Scenario: upgrade all with --security with advisory fix available upgrades even with --nobest
Given I use repository "security-upgrade"
  And I execute dnf with args "install dracut-1-1 kexec-tools-1-1"
 When I execute dnf with args "upgrade --security --nobest"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                  |
      | upgrade       | kexec-tools-0:2-2.x86_64 |
      | upgrade       | dracut-0:2-2.x86_64      |


Scenario: --security upgrade with advisory for obsoleter when obsoleted installed
Given I use repository "security-upgrade"
  And I execute dnf with args "install A-1-1"
 When I execute dnf with args "upgrade --security"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package        |
      | install       | B-0:2-2.x86_64 |
      | obsoleted     | A-0:1-1.x86_64 |
