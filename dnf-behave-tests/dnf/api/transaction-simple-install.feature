@dnf5
@not.with_dnf=4
Feature: transaction: install a package without dependencies


Scenario: Construct query and install labirinto package
Given I use repository "simple-base"
 When I execute python libdnf5 api script with setup
      """
      goal = libdnf5.base.Goal(base)
      goal.add_rpm_install("labirinto")
      transaction = goal.resolve()

      for tspkg in transaction.get_transaction_packages():
      	  print(tspkg.get_package().get_nevra(), ":", libdnf5.base.transaction.transaction_item_action_to_string(tspkg.get_action()))

      downloader = libdnf5.repo.PackageDownloader()
      downloader_callbacks = libdnf5.repo.DownloadCallbacks()
      downloader_callbacks_ptr = libdnf5.repo.DownloadCallbacksUniquePtr(downloader_callbacks)

      for tspkg in transaction.get_transaction_packages():
        if libdnf5.base.transaction.transaction_item_action_is_inbound(tspkg.get_action()):
            downloader.add(tspkg.get_package(), downloader_callbacks_ptr)

      downloader.download(True, True)

      transaction_callbacks = libdnf5.rpm.TransactionCallbacks()
      transaction_callbacks_ptr = libdnf5.rpm.TransactionCallbacksUniquePtr(transaction_callbacks)

      transaction.run(transaction_callbacks_ptr, "install package labirinto", None, None)
      """
   Then the exit code is 0
    And stdout is
 """
 labirinto-1.0-1.fc29.x86_64 : Install
 """
 When I execute rpm with args "-q labirinto"
   Then the exit code is 0
    And stdout contains "labirinto-1\.0-1\.fc29\.x86_64"
