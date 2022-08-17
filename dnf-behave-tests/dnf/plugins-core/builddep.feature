# Unknown argument "builddep" for command "microdnf"
Feature: dnf builddep command


Background: Enable builddep plugin
  Given I enable plugin "builddep"


Scenario: Dnf builddep can use spec file from a remote location
  Given I use repository "dnf-ci-fedora"
    And I create directory "/remotedir"
    And I create file "/remotedir/pkg.spec" with
    """
    Name: pkg
    Version: 1
    Release: 1
    Summary: summary
    License: license

    BuildRequires: filesystem

    %description
    desc
    """
    And I set up a http server for directory "/remotedir"
   When I execute dnf with args "builddep http://localhost:{context.dnf.ports[/remotedir]}/pkg.spec"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |

@dnf5
Scenario: Builddep with simple dependency (spec)
    Given I use repository "dnf-ci-fedora"
     When I execute dnf with args "builddep {context.dnf.fixturesdir}/specs/dnf-ci-thirdparty/SuperRipper-1.0-1.spec"
     Then the exit code is 0
      And Transaction is following
        | Action        | Package                           |
        | install       | lame-libs-0:3.100-4.fc29.x86_64   |

@dnf5
Scenario: Builddep with simple dependency (spec) + define
    Given I use repository "dnf-ci-fedora"
     When I execute dnf with args "builddep {context.dnf.fixturesdir}/specs/dnf-ci-thirdparty/SuperRipper-1.0-1.spec --define 'buildrequires flac'"
     Then the exit code is 0
      And Transaction is following
        | Action        | Package                           |
        | install       | flac-0:1.3.2-8.fc29.x86_64        |

@dnf5
Scenario: Builddep with simple dependency (srpm)
    Given I use repository "dnf-ci-fedora"
     When I execute dnf with args "builddep {context.dnf.fixturesdir}/repos/dnf-ci-thirdparty/src/SuperRipper-1.0-1.src.rpm"
     Then the exit code is 0
      And Transaction is following
        | Action        | Package                           |
        | install       | lame-libs-0:3.100-4.fc29.x86_64   |

@dnf5
@not.with_os=rhel__eq__7
Scenario: Builddep with rich dependency
    Given I use repository "dnf-ci-fedora"
     When I execute dnf with args "builddep {context.dnf.fixturesdir}/specs/dnf-ci-thirdparty/SuperRipper-1.0-1.spec --define 'buildrequires (flac and lame-libs)'"
     Then the exit code is 0
      And Transaction is following
        | Action        | Package                           |
        | install       | flac-0:1.3.2-8.fc29.x86_64        |
        | install       | lame-libs-0:3.100-4.fc29.x86_64   |

@dnf5
Scenario: Builddep with simple dependency (files-like provide)
    Given I use repository "dnf-ci-fedora"
     When I execute dnf with args "builddep {context.dnf.fixturesdir}/specs/dnf-ci-thirdparty/SuperRipper-1.0-1.spec --define 'buildrequires /etc/ld.so.conf'"
     Then the exit code is 0
      And Transaction contains
        | Action        | Package                           |
        | install       | glibc-0:2.28-9.fc29.x86_64        |

# @dnf5
# TODO(nsella) different exit code
Scenario: Builddep with simple dependency (non-existent)
    Given I use repository "dnf-ci-fedora"
     When I execute dnf with args "builddep {context.dnf.fixturesdir}/specs/dnf-ci-thirdparty/SuperRipper-1.0-1.spec --define 'buildrequires flac = 15'"
     Then the exit code is 1
      And stderr contains "No matching package to install: 'flac = 15'"

# @dnf5
# TODO(nsella) different exit code
@bz1724668
Scenario: Builddep on SPEC with non-available Source0
 Given I create file "{context.dnf.installroot}/missingSource.spec" with
   """
   Name: dummy-pkg
   Summary: dummy-pkg summary
   Version: 1.0
   Release: 1
   License: GPL
   Source0: no-such-archive.tar.gz
   %description
   This is a dummy-pkg description
   %build
   %files
   %changelog
   """
  When I execute dnf with args "builddep {context.dnf.installroot}/missingSource.spec"
  Then the exit code is 1
   And stderr matches line by line
   """
   RPM: error: Unable to open .*/missingSource.spec: No such file or directory
   Failed to open: '.*/missingSource.spec', not a valid spec file: can't parse specfile

   Error: Some packages could not be found.
   """

@dnf5
@bz1758459
Scenario: I exclude the highest verion of a package and call dnf builddep with --best
  Given I use repository "dnf-ci-fedora-updates"
    And I create file "dummy-pkg.spec" with
   """
   Name: dummy-pkg
   Summary: dummy-pkg summary
   Version: 1.0
   Release: 1
   License: GPL
   BuildRequires: flac
   %description
   This is a dummy-pkg description
   %build
   %files
   %changelog
   """
   When I execute dnf with args "builddep {context.dnf.installroot}/dummy-pkg.spec --exclude flac-1.3.3-3.fc29 --best"
   Then the exit code is 0
    And Transaction is following
        | Action                | Package                    |
        | install               | flac-0:1.3.3-2.fc29.x86_64 |

# @dnf5
# TODO(nsella) different exit code
@bz1628634
Scenario: Builddep with unavailable build dependency
    Given I use repository "dnf-ci-fedora"
     When I execute dnf with args "builddep {context.dnf.fixturesdir}/repos/dnf-ci-builddep/src/unavailable-requirement-1.0-1.src.rpm"
     Then the exit code is 1
      And stderr is
      """
      No matching package to install: 'this-lib-is-not-available'
      Not all dependencies satisfied
      Error: Some packages could not be found.
      """
     When I execute dnf with args "builddep --skip-unavailable {context.dnf.fixturesdir}/repos/dnf-ci-builddep/src/unavailable-requirement-1.0-1.src.rpm"
     Then the exit code is 0
      And stderr is
      """
      No matching package to install: 'this-lib-is-not-available'
      """
      And Transaction is following
        | Action        | Package                           |
        | install       | lame-libs-0:3.100-4.fc29.x86_64   |

@dnf5
@bz2077820
Scenario: Builddep using macros with source rpm
    Given I use repository "dnf-ci-fedora"
     When I execute dnf with args "builddep -D 'dummy_param 1' {context.dnf.fixturesdir}/repos/dnf-ci-thirdparty/src/SuperRipper-1.0-1.src.rpm"
     Then the exit code is 0
      And stderr contains "Warning: -D or --define arguments have no meaning for source rpm packages."
