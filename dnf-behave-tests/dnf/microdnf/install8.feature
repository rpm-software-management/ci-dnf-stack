Feature: microdnf is able to downgrade packages


@bz1855542
@bz1725863
Scenario: Install a package specifying a lower version than currently installed
Given I use repository "dnf-ci-fedora"
  And I use repository "dnf-ci-fedora-updates"
  And I successfully execute microdnf with args "install flac"
 When I execute microdnf with args "install flac-1.3.2-8.fc29"
 Then the exit code is 0
  And microdnf transaction is
      | Action        | Package                                   |
      | downgrade     | flac-0:1.3.2-8.fc29.x86_64                |
      | downgraded    | flac-0:1.3.3-3.fc29.x86_64                |
