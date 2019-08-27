Feature: Tests for installing RPM from paths


Scenario Outline: I can install an RPM from path, where path is <path type>
  Given I use the repository "dnf-ci-fedora"
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

