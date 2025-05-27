Feature: Subtitute variables

Background:
  Given I use repository "dnf-ci-fedora" with configuration
        | key                 | value                                        |
        | baseurl             | $var1{context.scenario.repos_location}/$var2 |
        | skip_if_unavailable | false                                        |


@bz2076853
Scenario: Variables are substituted in baseurl via vars in config files
  Given I create and substitute file "/etc/dnf/vars/var1" with
        """
        file://
        """
    And I create and substitute file "/etc/dnf/vars/var2" with
        """
        dnf-ci-fedora
        """
    And I execute microdnf with args "repoquery setup"
   Then the exit code is 0


@bz2076853
Scenario: Variables are substituted in baseurl via vars in config files, installroot variant
  Given I create and substitute file "/etc/dnf/vars/var1" with
        """
        file://
        """
    And I create and substitute file "/etc/dnf/vars/var2" with
        """
        dnf-ci-fedora
        """
    And I execute microdnf with args "repoquery setup"
   Then the exit code is 0


@bz2076853
Scenario: Variables are substituted in baseurl via vars in config files in custom location
  Given I create and substitute file "/tmp/vars/var1" with
        """
        file://
        """
    And I create and substitute file "/tmp/vars/var2" with
        """
        dnf-ci-fedora
        """
  When I execute microdnf with args "install setup"
    Then the exit code is 1
  When I execute microdnf with args "install setup --setopt=varsdir={context.dnf.installroot}/tmp/vars"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                       |
        | install       | setup-0:2.12.1-1.fc29.noarch  |


@bz2076853
Scenario: Variables are substituted in baseurl via environment variables
  Given I set environment variable "DNF_VAR_var1" to "file://"
    And I set environment variable "DNF_VAR_var2" to "dnf-ci-fedora"
    And I execute microdnf with args "install setup"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                       |
        | install       | setup-0:2.12.1-1.fc29.noarch  |
