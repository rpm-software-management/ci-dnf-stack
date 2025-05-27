Feature: Reinstall


# Since the Curl error messages were updated in f41 run the test only there
@not.with_os=fedora__lt__41
Scenario: Try to reinstall a pkg if repo not available
Scenario: Try to reinstall a pkg if repo not available and skip_if_unavailable is disabled
  Given I use repository "simple-base"
    And I successfully execute microdnf with args "install labirinto"
   When I use repository "simple-base" with configuration
        | key                 | value                               |
        | baseurl             | https://www.not-available-repo.com/ |
        | skip_if_unavailable | false                               |
   When I execute microdnf with args "reinstall labirinto"
   Then the exit code is 1
   And stderr is
       """
       error: cannot update repo 'simple-base': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried; Last error: Curl error (6): Could not resolve hostname for https://www.not-available-repo.com/repodata/repomd.xml [Could not resolve host: www.not-available-repo.com]
       """
