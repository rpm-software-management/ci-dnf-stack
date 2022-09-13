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


Scenario: --security upgrade with advisory for obsoleter B with two versions 1-1 and 2-2 when obsoleted A is installed
Given I use repository "security-upgrade"
  And I execute dnf with args "install A-1-1"
 When I execute dnf with args "upgrade --security"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package        |
      | install       | B-0:2-2.x86_64 |
      | obsoleted     | A-0:1-1.x86_64 |


Scenario: --security upgrade with advisory for obsoleter with one version exactly matching advisory when obsoleted installed
Given I use repository "security-upgrade"
  And I execute dnf with args "install C-1-1"
 When I execute dnf with args "upgrade --security"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package        |
      | install       | D-0:1-1.x86_64 |
      | obsoleted     | C-0:1-1.x86_64 |


Scenario: --security upgrade with advisory for obsoleter with one bigger version than in advisory when obsoleted installed
Given I use repository "security-upgrade"
  And I execute dnf with args "install E-1-1"
 When I execute dnf with args "upgrade --security"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package        |
      | install       | F-0:2-2.x86_64 |
      | obsoleted     | E-0:1-1.x86_64 |


@bz2124483
Scenario: --security upgrade of a package that changes arch from noarch to x86_64
Given I use repository "security-upgrade"
  And I execute dnf with args "install change-arch-noarch-1-1.noarch"
 When I execute dnf with args "upgrade --security"
 Then the exit code is 0
  And RPMDB Transaction is following
      | Action        | Package                  |
      | install       | change-arch-noarch-0:2-2.x86_64 |
      | remove        | change-arch-noarch-0:1-1.noarch |
  And DNF Transaction is following
      | Action        | Package                  |
      | upgrade       | change-arch-noarch-0:2-2.x86_64 |


@bz2124483
Scenario: --security upgrade of a package that changes arch from x86_64 to noarch
Given I use repository "security-upgrade"
  And I execute dnf with args "install change-arch-noarch-reversed-1-1.x86_64"
 When I execute dnf with args "upgrade --security"
 Then the exit code is 0
  And RPMDB Transaction is following
      | Action        | Package                           |
      | install       | change-arch-noarch-reversed-0:2-2.noarch |
      | remove        | change-arch-noarch-reversed-0:1-1.x86_64 |
  And DNF Transaction is following
      | Action        | Package                           |
      | upgrade       | change-arch-noarch-reversed-0:2-2.noarch |


@bz2124483
Scenario: --security upgrade of a package that changes arch from i686 to x86_64 is not allowed
Given I use repository "security-upgrade"
  And I successfully execute dnf with args "install change-arch-1-1.i686"
  # Make sure change-arch-2-2.x86_64 is available since we are testing we don't upgrade to it.
  # It also has to have an available advisory. (We cannot verify that here because the updateinfo command is bugged when dealing with arch changes)
  And I successfully execute dnf with args "repoquery change-arch-2-2.x86_64"
  Then stdout is
  """
  <REPOSYNC>
  change-arch-0:2-2.x86_64
  """
 When I execute dnf with args "upgrade --security"
 Then the exit code is 0
  And Transaction is empty


@bz2124483
Scenario: --security upgrade of a package that changes arch from x86_64 to i686 is not allowed
Given I use repository "security-upgrade"
  And I successfully execute dnf with args "install change-arch-reversed-1-1.x86_64"
  # Make sure change-arch-reversed-2-2.i686 is available and has an adivosry since we are testing we don't upgrade to it.
  # It also has to have an available advisory. (We cannot verify that here because the updateinfo command is bugged when dealing with arch changes)
  And I successfully execute dnf with args "repoquery change-arch-reversed-2-2.i686"
  Then stdout is
  """
  <REPOSYNC>
  change-arch-reversed-0:2-2.i686
  """
 When I execute dnf with args "upgrade --security"
 Then the exit code is 0
  And Transaction is empty


@bz2124483
Scenario: --security upgrade of a noarch package that is obsoleted by a x86_64 pkg
Given I use repository "security-upgrade-obsoletes"
  And I successfully execute dnf with args "install obsoleted-change-arch-noarch-1-1.noarch"
 When I execute dnf with args "upgrade --security"
 Then the exit code is 0
  And RPMDB Transaction is following
      | Action        | Package                                   |
      | install       | obsoleter-change-arch-noarch-0:1-1.x86_64 |
      | remove        | obsoleted-change-arch-noarch-0:1-1.noarch |
  And DNF Transaction is following
      | Action        | Package                                   |
      | install       | obsoleter-change-arch-noarch-1-1.x86_64   |
      | obsoleted     | obsoleted-change-arch-noarch-0:1-1.noarch |


@bz2124483
Scenario: --security upgrade of a x86_64 package that is obsoleted by a noarch pkg
Given I use repository "security-upgrade-obsoletes"
  And I successfully execute dnf with args "install obsoleted-change-arch-noarch-reversed-1-1.x86_64"
 When I execute dnf with args "upgrade --security"
 Then the exit code is 0
  And RPMDB Transaction is following
      | Action        | Package                                            |
      | install       | obsoleter-change-arch-noarch-reversed-0:1-1.noarch |
      | remove        | obsoleted-change-arch-noarch-reversed-0:1-1.x86_64 |
  And DNF Transaction is following
      | Action        | Package                                            |
      | install       | obsoleter-change-arch-noarch-reversed-1-1.noarch   |
      | obsoleted     | obsoleted-change-arch-noarch-reversed-0:1-1.x86_64 |


@bz2124483
Scenario: --security upgrade of a i686 package that is obsoleted by a x86_64 pkg is not allowed
Given I use repository "security-upgrade-obsoletes"
  And I successfully execute dnf with args "install obsoleted-change-arch-1-1.i686"
  # Make sure obsoleter-change-arch-1-1.x86_64 and obsoleter-change-arch-1-1.i686 are available and obsolete obsoleted-change-arch since we are testing we don't upgrade to any of them.
  # There also should be an available advisory for obsoleter-change-arch-1-1.x86_64. (We cannot verify that here because the updateinfo command is bugged when dealing with obsoletes)
  And I successfully execute dnf with args "repoquery obsoleter-change-arch-1-1.x86_64 --obsoletes"
  Then stdout is
  """
  <REPOSYNC>
  obsoleted-change-arch
  """
Given I successfully execute dnf with args "repoquery obsoleter-change-arch-1-1.i686 --obsoletes"
  Then stdout is
  """
  <REPOSYNC>
  obsoleted-change-arch
  """
 When I execute dnf with args "upgrade --security"
 Then the exit code is 0
  And Transaction is empty


@bz2124483
Scenario: --security upgrade of a x86_64 package that is obsoleted by a i686 pkg is not allowed
Given I use repository "security-upgrade-obsoletes"
  And I successfully execute dnf with args "install obsoleted-change-arch-reversed-1-1.x86_64"
  # Make sure obsoleter-change-arch-reversed-1-1.x86_64 and obsoleter-change-arch-reversed-1-1.i686 are available and obsolete obsoleted-change-arch-reversed since we are testing we don't upgrade to any of them.
  # There also should be an available advisory for obsoleter-change-arch-reversed-1-1.i686. (We cannot verify that here because the updateinfo command is bugged when dealing with obsoletes)
  And I successfully execute dnf with args "repoquery obsoleter-change-arch-reversed-1-1.x86_64 --obsoletes"
  Then stdout is
  """
  <REPOSYNC>
  obsoleted-change-arch-reversed
  """
Given I successfully execute dnf with args "repoquery obsoleter-change-arch-reversed-1-1.i686 --obsoletes"
  Then stdout is
  """
  <REPOSYNC>
  obsoleted-change-arch-reversed
  """
 When I execute dnf with args "upgrade --security"
 Then the exit code is 0
  And Transaction is empty


Scenario: --security upgrade specific package with obsoletes when obsoletes are turned off
Given I use repository "security-upgrade"
  And I execute dnf with args "install E-1-1"
  # Make sure F-2-2 is available and obsoletes E since we are testing we don't upgrade to it.
  # There also should be an available advisory for it. (We cannot verify that here because the updateinfo command is bugged when dealing with obsoletes)
  And I successfully execute dnf with args "repoquery F-2-2.x86_64 --obsoletes"
  Then stdout is
  """
  <REPOSYNC>
  E
  """
  When I execute dnf with args "upgrade E --security --setopt=obsoletes=false"
 Then the exit code is 0
  And Transaction is empty


@xfail
# This has likely never worked on dnf4, it will be fixed in dnf5
Scenario: --security upgrade all packages with obsoletes when obsoletes are turned off
Given I use repository "security-upgrade"
  And I execute dnf with args "install E-1-1"
  # Make sure F-2-2 is available and obsoletes E since we are testing we don't upgrade to it.
  # There also should be an available advisory for it. (We cannot verify that here because the updateinfo command is bugged when dealing with obsoletes)
  And I successfully execute dnf with args "repoquery F-2-2.x86_64 --obsoletes"
  Then stdout is
  """
  <REPOSYNC>
  E
  """
  When I execute dnf with args "upgrade --security --setopt=obsoletes=false"
 Then the exit code is 0
  And Transaction is empty
