Feature: Repolist with enabled/disabled repositories

  @setup
  Scenario: Feature Setup
      Given empty repository "TestA"
        And empty repository "TestB"
        And repository "TestC" with packages
         | Package | Tag | Value |
         | TestA   |     |       |
         | TestB   |     |       |
         | TestC   |     |       |
       When I enable repository "TestB"
        And I enable repository "TestC"
        And I successfully run "dnf makecache"

  Scenario: Repolist without arguments
       When I successfully run "dnf repolist"
       Then the command stdout should match exactly
            """
            repo id                               repo name                           status
            TestB                                 TestB                               0
            TestC                                 TestC                               3

            """

  Scenario: Repolist with "enabled"
       When I successfully run "dnf repolist enabled"
       Then the command stdout should match exactly
            """
            repo id                               repo name                           status
            TestB                                 TestB                               0
            TestC                                 TestC                               3

            """

  Scenario: Repolist with "disabled"
       When I successfully run "dnf repolist disabled"
       Then the command stdout should match exactly
            """
            repo id                                 repo name                               
            TestA                                   TestA                                   
            TestA-source                            TestA-source                            
            TestB-source                            TestB-source                            
            TestC-source                            TestC-source                            

            """

  Scenario: Repolist with "all"
       When I successfully run "dnf repolist all"
       Then the command stdout should match exactly
            """
            repo id                            repo name                          status
            TestA                              TestA                              disabled
            TestA-source                       TestA-source                       disabled
            TestB                              TestB                              enabled: 0
            TestB-source                       TestB-source                       disabled
            TestC                              TestC                              enabled: 3
            TestC-source                       TestC-source                       disabled

            """
