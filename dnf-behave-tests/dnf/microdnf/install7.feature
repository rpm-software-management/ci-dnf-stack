Feature: Install package


@bz1691353
Scenario: Install an RPM without null lines
  Given I use repository "dnf-ci-fedora"
   When I execute microdnf with args "install lame"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | install       | lame-0:3.100-4.fc29.x86_64                |
        | install       | lame-libs-0:3.100-4.fc29.x86_64           |
  And stdout does not contain "Installing: (null)"

