Feature: check-update commands

@bz1769466
Scenario: check for updates according to priority
Given I use repository "dnf-ci-fedora"
 When I execute dnf with args "install glibc"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                                   |
      | install       | glibc-0:2.28-9.fc29.x86_64                |
      | install-dep   | basesystem-0:11-6.fc29.noarch             |
      | install-dep   | filesystem-0:3.9-2.fc29.x86_64            |
      | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
      | install-dep   | glibc-common-0:2.28-9.fc29.x86_64         |
      | install-dep   | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
Given I use repository "dnf-ci-fedora-updates"
 When I execute dnf with args "check-update"
 Then the exit code is 100
 Then stdout contains "glibc.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora-updates"
 Then stdout contains "glibc-common.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora-updates"
 Then stdout contains "glibc-all-langpacks.x86_64\s+2.28-26.fc29\s+dnf-ci-fedora-updates"
Given I use repository "dnf-ci-fedora-updates" with configuration
      | key           | value   |
      | priority      | 100     |
 When I execute dnf with args "check-update"
 Then the exit code is 0
 When I execute dnf with args "upgrade"
 Then the exit code is 0
  And Transaction is empty


@bz2101421
Scenario: --security check-update doesn't show pkgs from resolved advisories (when obsoletes are involved)
Given I use repository "check-update"
  And I execute dnf with args "install A-1-1"
 When I execute dnf with args "update --security"
 Then the exit code is 0
  And Transaction is empty
 When I execute dnf with args "check-update --security"
 Then the exit code is 0
  And stdout is
  """
  <REPOSYNC>
  """
