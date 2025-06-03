Feature: microdnf install command on packages


@bz1734350
@bz1779757
Scenario: Install package from local repodata with local packages
#1. local repo with local packages
Given I use repository "dnf-ci-fedora"
 When I execute microdnf with args "install kernel"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                                   |
      | install       | kernel-core-0:4.18.16-300.fc29.x86_64     |
      | install       | kernel-modules-0:4.18.16-300.fc29.x86_64  |
      | install       | kernel-0:4.18.16-300.fc29.x86_64          |
