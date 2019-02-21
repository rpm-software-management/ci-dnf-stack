Feature: Test for repoquery option --location

  @setup
  Scenario: Feature Setup
      Given repository "base" with packages
          | Package     | Tag       | Value             |
          | TestA       | Version   | 1                 |
          | TestB       | Version   | 1                 |
       When I enable repository "base"

  @bz1639827
  Scenario: repoquery --location
       When I run "dnf repoquery TestA --location"
       Then the command should pass
        And the command stdout should match regexp output of "sh -c 'dnf repoinfo base | grep "^Repo-baseurl" | sed "s|.*file://\(.*\)|\1/TestA-1-1.noarch.rpm|"'"
