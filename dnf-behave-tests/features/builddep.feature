Feature: Builddep

Scenario: Builddep with simple dependency (spec)
    Given I use the repository "dnf-ci-fedora"
      And I enable plugin "builddep"
     When I execute dnf with args "builddep {context.dnf.fixturesdir}/specs/dnf-ci-thirdparty/SuperRipper-1.0-1.spec"
     Then the exit code is 0
      And Transaction is following
        | Action        | Package                           |
        | install       | lame-libs-0:3.100-4.fc29.x86_64   |

Scenario: Builddep with simple dependency (spec) + define
    Given I use the repository "dnf-ci-fedora"
      And I enable plugin "builddep"
     When I execute dnf with args "builddep {context.dnf.fixturesdir}/specs/dnf-ci-thirdparty/SuperRipper-1.0-1.spec --define 'buildrequires flac'"
     Then the exit code is 0
      And Transaction is following
        | Action        | Package                           |
        | install       | flac-0:1.3.2-8.fc29.x86_64        |

Scenario: Builddep with simple dependency (srpm)
    Given I use the repository "dnf-ci-fedora"
      And I enable plugin "builddep"
     When I execute dnf with args "builddep {context.dnf.fixturesdir}/repos/dnf-ci-thirdparty/src/SuperRipper-1.0-1.src.rpm"
     Then the exit code is 0
      And Transaction is following
        | Action        | Package                           |
        | install       | lame-libs-0:3.100-4.fc29.x86_64   |

Scenario: Builddep with rich dependency
    Given I use the repository "dnf-ci-fedora"
      And I enable plugin "builddep"
     When I execute dnf with args "builddep {context.dnf.fixturesdir}/specs/dnf-ci-thirdparty/SuperRipper-1.0-1.spec --define 'buildrequires (flac and lame-libs)'"
     Then the exit code is 0
      And Transaction is following
        | Action        | Package                           |
        | install       | flac-0:1.3.2-8.fc29.x86_64        |
        | install       | lame-libs-0:3.100-4.fc29.x86_64   |

Scenario: Builddep with simple dependency (files-like provide)
    Given I use the repository "dnf-ci-fedora"
      And I enable plugin "builddep"
     When I execute dnf with args "builddep {context.dnf.fixturesdir}/specs/dnf-ci-thirdparty/SuperRipper-1.0-1.spec --define 'buildrequires /etc/ld.so.conf'"
     Then the exit code is 0
      And Transaction contains
        | Action        | Package                           |
        | install       | glibc-0:2.28-9.fc29.x86_64        |

Scenario: Builddep with simple dependency (non-existent)
    Given I use the repository "dnf-ci-fedora"
      And I enable plugin "builddep"
      When I execute dnf with args "builddep {context.dnf.fixturesdir}/specs/dnf-ci-thirdparty/SuperRipper-1.0-1.spec --define 'buildrequires (flac=15)'"
     Then the exit code is 1
      And stderr contains "No matching package to install: '\(flac=15\)'"
