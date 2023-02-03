@dnf5
Feature: transaction: dry-run a transaction


@bz2109660
Scenario: Test labirinto install transaction when it should succeed
Given I use repository "simple-base"
 When I execute python libdnf5 api script with setup
      """
      goal = libdnf5.base.Goal(base)
      goal.add_rpm_install("labirinto")
      assert test_transaction(goal) == libdnf5.base.Transaction.TransactionRunResult_SUCCESS
      """
 Then the exit code is 0
  And stderr is empty

@bz2109660
Scenario: Test labirinto install transaction when it should fail
Given I use repository "simple-base"
 When I execute python libdnf5 api script with setup
      """
      goal = libdnf5.base.Goal(base)
      goal.add_rpm_install("labirinto")
      execute_transaction(goal, "install a package")

      # We have already run the transaction, so test_transaction should return a failing status
      assert test_transaction(goal) == libdnf5.base.Transaction.TransactionRunResult_ERROR_RPM_RUN
      """
 Then the exit code is 0
  And stderr is empty
