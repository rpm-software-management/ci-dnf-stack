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
            repo id                                 repo name                               
            TestA                                   TestA                                   
            TestA-source                            TestA-source                            
            TestB                                   TestB                                   
            TestB-source                            TestB-source                            
            TestC                                   TestC                                   
            TestC-source                            TestC-source                            

            """

  Scenario: Repolist with "all"
       When I successfully run "dnf repolist all"
       Then the command stdout should match exactly
            """
            repo id                             repo name                           status
            TestA                               TestA                               disabled
            TestA-source                        TestA-source                        disabled
            TestB                               TestB                               disabled
            TestB-source                        TestB-source                        disabled
            TestC                               TestC                               disabled
            TestC-source                        TestC-source                        disabled

            """
