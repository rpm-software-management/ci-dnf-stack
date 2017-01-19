Feature: Repolist when all repositories are disabled

  @setup
  Scenario: Feature Setup
      Given empty repository "TestA"
        And empty repository "TestB"
        And empty repository "TestC"

  Scenario: Repolist without arguments
       When I successfully run "dnf repolist"
       Then the command stdout should be empty

  Scenario: Repolist with "enabled"
       When I successfully run "dnf repolist enabled"
       Then the command stdout should be empty

  Scenario: Repolist with "disabled"
       When I successfully run "dnf repolist disabled"
       Then the command stdout should match exactly
            """
            repo id                                  repo name                              
            TestA                                    TestA                                  
            TestB                                    TestB                                  
            TestC                                    TestC                                  

            """

  Scenario: Repolist with "all"
       When I successfully run "dnf repolist all"
       Then the command stdout should match exactly
            """
            repo id                              repo name                          status
            TestA                                TestA                              disabled
            TestB                                TestB                              disabled
            TestC                                TestC                              disabled

            """
