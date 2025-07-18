Feature: Test for successful and failing rpm scriptlets


Background: Enable repository
  Given I use repository "scriptlets"


@dnf5
Scenario Outline: Install a pkg with a successful scriptlet
   When I execute dnf with args "install <package>"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                  |
        | install       | <package>-0:1.0-1.x86_64 |
    And stdout contains "<output>"

Examples:
      | package              | output                                |
      | Package-pre-ok       | pre scriptlet successfully done       |
      | Package-pretrans-ok  | pretrans scriptlet successfully done  |
      | Package-post-ok      | post scriptlet successfully done      |
      | Package-posttrans-ok | posttrans scriptlet successfully done |


# @dnf5
# TODO(nsella) different exit code
Scenario Outline: Install a pkg with a failing %pre[IN|TRANS] scriptlet
  When I execute dnf with args "install <package>"
  Then the exit code is 1
   And stderr contains "Error in <scriptlet> scriptlet in rpm package <package>"
   And stderr contains "Error: Transaction failed"
       
Examples:
      | package               | scriptlet |
      | Package-pre-fail      | PREIN     |
      | Package-pretrans-fail | PRETRANS  |


# Disable on older fedoras because they don't contain new rpm-6.0.0
@not.with_os=fedora__lt__43
# @dnf5
# TODO(nsella) different stderr
Scenario Outline: Install a pkg with a failing %post[in|trans] scriptlet
  When I execute dnf with args "install <package>"
  Then the exit code is 1
   And Transaction is following
       | Action        | Package                  |
       | install       | <package>-0:1.0-1.x86_64 |
   And stderr contains "Error in <scriptlet> scriptlet in rpm package <package>"
       
Examples:
      | package                | scriptlet |
      | Package-post-fail      | POSTIN |
      | Package-posttrans-fail | POSTTRANS |


@dnf5
Scenario Outline: Remove a pkg with a successful %[pre|post]un scriptlet
  When I execute dnf with args "install <package>"
  Then the exit code is 0
   And Transaction is following
       | Action        | Package                  |
       | install       | <package>-0:1.0-1.x86_64 |
  When I execute dnf with args "remove <package>"
  Then the exit code is 0
   And stdout contains "<output>"
       
Examples:
      | package           | output    |
      | Package-preun-ok  | preun scriptlet successfully done  |
      | Package-postun-ok | postun scriptlet successfully done |


# @dnf5
# TODO(nsella) different exit code
Scenario: Remove a pkg with a failing %preun scriptlet
  When I execute dnf with args "install Package-preun-fail"
  Then the exit code is 0
   And Transaction is following
       | Action        | Package                           |
       | install       | Package-preun-fail-0:1.0-1.x86_64 |
  When I execute dnf with args "remove Package-preun-fail"
  Then the exit code is 1
   And stderr contains "Error in PREUN scriptlet in rpm package Package-preun-fail"
   And stderr contains "Error: Transaction failed"
  When I execute dnf with args "--setopt=tsflags=noscripts remove Package-preun-fail"
  Then the exit code is 0
   And Transaction is following
       | Action        | Package                           |
       | remove        | Package-preun-fail-0:1.0-1.x86_64 |


# Disable on older fedoras because they don't contain new rpm-6.0.0
@not.with_os=fedora__lt__43
# @dnf5
# TODO(nsella) different stderr
Scenario: Remove a pkg with a failing %postun scriptlet
  When I execute dnf with args "install Package-postun-fail"
  Then the exit code is 0
   And Transaction is following
       | Action        | Package                            |
       | install       | Package-postun-fail-0:1.0-1.x86_64 |
  When I execute dnf with args "remove Package-postun-fail"
  Then the exit code is 1
   And stderr contains "Error in POSTUN scriptlet in rpm package Package-postun-fail"
   And Transaction is following
       | Action        | Package                           |
       | remove        | Package-postun-fail-0:1.0-1.x86_64 |


# The patch for printing correct pacakges whose the running scriptlet is had to be reverted because it broke DNF API.
# The fix is delayed to DNF5 because is will use C rpm API instead of the Python one
@xfail
@bz1724779
Scenario: Output for triggered successful scriptlet of a package not present in transaction has temporarily just pkg name
 Given I successfully execute dnf with args "install Package-triggerin-ok"
  When I execute dnf with args "install Package-install-file"
  Then the exit code is 0
   And Transaction is following
       | Action        | Package                             |
       | install       | Package-install-file-0:1.0-1.x86_64 |
   And stdout contains "triggerin scriptlet \(Package-triggerin-ok\) for Package-install-file install/update successfully done"
   And stdout does not contain "Running scriptlet\s*:\s*Package-install-file"
   And stdout contains "Running scriptlet\s*:\s*Package-triggerin-ok-1.0-1.x86_64"


# Disable on older fedoras because they don't contain new rpm-6.0.0
@not.with_os=fedora__lt__43
@xfail
@bz1724779
Scenario: Correct output for triggered failed scriptlet of package not present in transaction
 Given I successfully execute dnf with args "install Package-triggerin-fail"
  When I execute dnf with args "install Package-install-file"
  Then the exit code is 1
   And stdout contains "failing on triggerin scriptlet"
   And stdout contains "Running scriptlet\s*:\s*Package-triggerin-fail-1.0-1.x86_64"
   And stdout does not contain "Running scriptlet\s*:\s*Package-install-file"
   # There is an RPM problem, where it doesn't export internal tag for %triggerin, therefore DNF prints <unknown> instead
   # And stderr is 
   # """
   # Error in %triggerin scriptlet in rpm package Package-triggerin-fail triggered by rpm package Package-install-file-1.0-1.x86_64
   # """
   And stderr is 
   """
   Error in <unknown> scriptlet in rpm package Package-triggerin-fail triggered by rpm package Package-install-file-1.0-1.x86_64
   """


# Disable on older fedoras because they don't contain new rpm-6.0.0
@not.with_os=fedora__lt__43
@xfail
@bz1724779
Scenario: Correct output for triggered failing transfiletriggerpostun scriptlet of package not present in transaction
 Given I successfully execute dnf with args "install Package-transfiletriggerpostun-fail"
   And I successfully execute dnf with args "install Package-install-file"
  When I execute dnf with args "remove Package-install-file"
  Then the exit code is 1
   And Transaction is following
       | Action        | Package                            |
       | remove       | Package-install-file-0:1.0-1.x86_64 |
   And stdout contains "transfiletriggerpostun scriptlet \(Package-transfiletriggerpostun-fail\) for uninstall transaction of Package-install-file is failing"
   And stdout contains "Running scriptlet\s*:\s*Package-transfiletriggerpostun-fail-1.0-1.x86_64"
   And stdout does not contain "Running scriptlet\s*:\s*Package-install-file"
   #"""
   #Error in %filetriggerin scriptlet in rpm package Package-transfiletriggerpostun-fail triggered by rpm package Package-install-file-1.0-1.x86_64
   #"""
   And stderr is 
   """
   Error in <unknown> scriptlet in rpm package Package-transfiletriggerpostun-fail triggered by rpm package Package-install-file-1.0-1.x86_64
   """


@bz1724779
# Another RPM problem where it provides wrong pkg in the callback for FILETRIGGERIN, should be fixed by https://github.com/rpm-software-management/rpm/pull/892
@xfail
Scenario: Correct output for triggered successful file scriptlet of package not present in transaction
 Given I successfully execute dnf with args "install Package-filetriggerin-ok"
  When I execute dnf with args "install Package-install-file"
  Then the exit code is 0
   And Transaction is following
       | Action        | Package                             |
       | install       | Package-install-file-0:1.0-1.x86_64 |
   And stdout contains "filetriggerin scriptlet \(Package-filetriggerin-ok\) for Package-install-file install/update successfully done"
   And stdout contains "Running scriptlet\s*:\s*Package-filetriggerin-ok-1.0-1.x86_64"
   And stdout does not contain "Running scriptlet\s*:\s*Package-install-file"


# Disable on older fedoras because they don't contain new rpm-6.0.0
@not.with_os=fedora__lt__43
@bz1724779
@xfail
Scenario: Correct output for triggered failing file scriptlet of package not present in transaction
 Given I successfully execute dnf with args "install Package-filetriggerin-fail"
  When I execute dnf with args "install Package-install-file"
  Then the exit code is 1
   And stdout contains "filetriggerin scriptlet \(Package-filetriggerin-fail\) for Package-install-file install/update is failing"
   And stdout contains "Running scriptlet\s*:\s*Package-filetriggerin-fail-1.0-1.x86_64"
   And stdout does not contain "Running scriptlet\s*:\s*Package-install-file"
   #"""
   #Error in %filetriggerin scriptlet in rpm package Package-transfiletriggerpostun-fail triggered by rpm package Package-install-file-1.0-1.x86_64
   #"""
   And stderr is 
   """
   Error in <unknown> scriptlet in rpm package Package-filetriggerin-fail triggered by rpm package Package-install-file-1.0-1.x86_64
   """


@xfail
@bz1724779
Scenario: Correct output for triggered successful transfiletriggerpostun scriptlet of package not present in transaction
 Given I successfully execute dnf with args "install Package-transfiletriggerpostun-ok"
   And I successfully execute dnf with args "install Package-install-file"
  When I execute dnf with args "remove Package-install-file"
  Then the exit code is 0
   And Transaction is following
       | Action        | Package                            |
       | remove       | Package-install-file-0:1.0-1.x86_64 |
   And stdout contains "transfiletriggerpostun scriptlet \(Package-transfiletriggerpostun-ok\) for Package-install-file transaction uninstall successfully done"
   And stdout contains "Running scriptlet\s*:\s*Package-transfiletriggerpostun-ok-1.0-1.x86_64"
   And stdout does not contain "Running scriptlet\s*:\s*Package-install-file"
