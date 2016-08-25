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

  Scenario: Repolist without arguments
       When I successfully run "dnf repolist"
       Then the command stdout should contain exactly
            """
            repo id                               repo name                           status
            TestB                                 TestB                               0
            TestC                                 TestC                               3

            """

  Scenario: Repolist with "enabled"
       When I successfully run "dnf repolist enabled"
       Then the command stdout should contain exactly
            """
            repo id                               repo name                           status
            TestB                                 TestB                               0
            TestC                                 TestC                               3

            """

  Scenario: Repolist with "disabled"
       When I successfully run "dnf repolist disabled"
       Then the command stdout should contain exactly
            """
            repo id                                  repo name                              
            TestA                                    TestA                                  

            """

  Scenario: Repolist with "all"
       When I successfully run "dnf repolist all"
       Then the command stdout should contain exactly
            """
            repo id                             repo name                         status
            TestA                               TestA                             disabled
            TestB                               TestB                             enabled: 0
            TestC                               TestC                             enabled: 3

            """
