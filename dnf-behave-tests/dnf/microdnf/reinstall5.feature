@no_installroot
Feature: Reinstall


Scenario: Try to reinstall a pkg if repo not available
  Given I use repository "simple-base"
    And I successfully execute microdnf with args "install labirinto"
   When I configure a new repository "non-existent" with
        | key                 | value                               |
        | baseurl             | https://www.not-available-repo.com/ |
        | enabled             | 1                                   |
        | skip_if_unavailable | 0                                   |
   When I execute microdnf with args "reinstall labirinto"
   Then the exit code is 1
   And stderr is
       """
       error: cannot update repo 'non-existent': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried; Last error: Curl error (6): Could not resolve hostname for https://www.not-available-repo.com/repodata/repomd.xml [Could not resolve host: www.not-available-repo.com]
       """
