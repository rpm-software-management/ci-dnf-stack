Feature: Subtitute releasever in baseurl


Scenario: Releasever is substituted in baseurl via a command line option
  Given I do not set releasever
    And I copy directory "{context.dnf.repos_location}/dnf-ci-fedora" to "/temp-repos/base-f0123"
    And I create and substitute file "/etc/yum.repos.d/test.repo" with
        """
        [testrepo]
        name=testrepo
        baseurl=file://{context.dnf.installroot}/temp-repos/base-f$releasever
        enabled=1
        gpgcheck=0
        """
    And I do not set reposdir
    And I use the repository "testrepo"
    And I execute dnf with args "install setup --releasever=0123"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                       |
        | install       | setup-0:2.12.1-1.fc29.noarch  |


Scenario: Releasever is substituted in baseurl via a config file
  Given I do not set releasever
    And I copy directory "{context.dnf.repos_location}/dnf-ci-fedora" to "/temp-repos/base-f0123"
    And I create and substitute file "/etc/yum.repos.d/test.repo" with
        """
        [testrepo]
        name=testrepo
        baseurl=file://{context.dnf.installroot}/temp-repos/base-f$releasever
        enabled=1
        gpgcheck=0
        """
    And I create and substitute file "/etc/dnf/vars/releasever" with
        """
        0123
        """
    And I do not set reposdir
    And I use the repository "testrepo"
    And I execute dnf with args "install setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                       |
        | install       | setup-0:2.12.1-1.fc29.noarch  |


Scenario: Releasever is substituted in baseurl via a value detected from a fedora-release package
  Given I do not set releasever
    And I execute rpm with args "-i --nodeps {context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/fedora-release-29-1.noarch.rpm"
    And I copy directory "{context.dnf.repos_location}/dnf-ci-fedora" to "/temp-repos/base-f29"
    And I create and substitute file "/etc/yum.repos.d/test.repo" with
        """
        [testrepo]
        name=testrepo
        baseurl=file://{context.dnf.installroot}/temp-repos/base-f$releasever
        enabled=1
        gpgcheck=0
        """
    And I do not set reposdir
    And I use the repository "testrepo"
    And I execute dnf with args "install setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                       |
        | install       | setup-0:2.12.1-1.fc29.noarch  |
