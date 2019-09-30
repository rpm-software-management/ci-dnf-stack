Feature: Subtitute releasever in baseurl

Background:
  Given I do not set releasever
    And I use repository "dnf-ci-fedora" with configuration
        | key     | value                                                         |
        | baseurl | file://{context.dnf.installroot}/temp-repos/base-f$releasever |

Scenario: Releasever is substituted in baseurl via a command line option
  Given I copy directory "{context.dnf.repos_location}/dnf-ci-fedora" to "/temp-repos/base-f0123"
    And I execute dnf with args "install setup --releasever=0123"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                       |
        | install       | setup-0:2.12.1-1.fc29.noarch  |


Scenario: Releasever is substituted in baseurl via a config file
  Given I copy directory "{context.dnf.repos_location}/dnf-ci-fedora" to "/temp-repos/base-f0123"
    And I create and substitute file "/etc/dnf/vars/releasever" with
        """
        0123
        """
    And I execute dnf with args "install setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                       |
        | install       | setup-0:2.12.1-1.fc29.noarch  |


Scenario: Releasever is substituted in baseurl via a value detected from a fedora-release package
  Given I execute rpm with args "-i --nodeps {context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/fedora-release-29-1.noarch.rpm"
    And I copy directory "{context.dnf.repos_location}/dnf-ci-fedora" to "/temp-repos/base-f29"
    And I execute dnf with args "install setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                       |
        | install       | setup-0:2.12.1-1.fc29.noarch  |


@bz1710761
Scenario: Releasever is substituted in baseurl via a value detected from 'system-release(releasever)' provide
  Given I execute rpm with args "-i --nodeps {context.dnf.fixturesdir}/repos/dnf-ci-fedora-release/noarch/fedora-release-29-1.noarch.rpm"
    And I copy directory "{context.dnf.repos_location}/dnf-ci-fedora" to "/temp-repos/base-f123"
    And I execute dnf with args "install setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                       |
        | install       | setup-0:2.12.1-1.fc29.noarch  |
