Feature: Tests for installing RPM from paths


Scenario Outline: I can install an RPM from path, where path is <path type>
   When I execute dnf with args "install <path>" from repo "dnf-ci-fedora"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |

Examples:
        | path type               | path                                                                                |
        | absolute                | {context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm |
        | relative                | noarch/setup-2.12.1-1.fc29.noarch.rpm                                               |
        | relative with wildcards | noarch/setup-*.fc29.noarch.rpm                                                      |
        | file://                 | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm |


Scenario: I can install an RPM from path, when specifying the RPM multiple times
   When I execute dnf with args "install noarch/setup-2.12.1-1.fc29.noarch.rpm noarch/setup-2.12.1-1.fc29.noarch.rpm" from repo "dnf-ci-fedora"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |


@xfail
Scenario: I can install an RPM from path, when specifying the RPM multiple times using different paths
   When I execute dnf with args "install noarch/setup-2.12.1-1.fc29.noarch.rpm {context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm" from repo "dnf-ci-fedora"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |


@xfail
Scenario: I can install an RPM from path, when specifying the RPM multiple times using symlink
  Given I copy file "{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm" to "/tmp/setup-2.12.1-1.fc29.noarch.rpm"
    And I create symlink "/tmp/symlink.rpm" to file "/tmp/setup-2.12.1-1.fc29.noarch.rpm"
   When I execute dnf with args "install {context.dnf.installroot}/tmp/setup-2.12.1-1.fc29.noarch.rpm {context.dnf.installroot}/tmp/symlink.rpm"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
