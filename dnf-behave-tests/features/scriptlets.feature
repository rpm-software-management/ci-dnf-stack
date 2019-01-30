Feature: Test for successful and failing rpm scriptlets


Background: Enable repository
  Given I use the repository "dnf-ci-scriptlets"


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


Scenario Outline: Install a pkg with a failing %pre[IN|TRANS] scriptlet
  When I execute dnf with args "install <package>"
  Then the exit code is 1
   And stderr contains "Error in <scriptlet> scriptlet in rpm package <package>"
   And stderr contains "Error: Transaction failed"
       
Examples:
      | package               | scriptlet |
      | Package-pre-fail      | PREIN     |
      | Package-pretrans-fail | PRETRANS  |


Scenario Outline: Install a pkg with a failing %post[in|trans] scriptlet
  When I execute dnf with args "install <package>"
  Then the exit code is 0
   And Transaction is following
       | Action        | Package                  |
       | install       | <package>-0:1.0-1.x86_64 |
   And stderr contains "Error in <scriptlet> scriptlet in rpm package <package>"
       
Examples:
      | package                | scriptlet |
      | Package-post-fail      | POSTIN |
      | Package-posttrans-fail | POSTTRANS |


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


Scenario: Remove a pkg with a failing %postun scriptlet
  When I execute dnf with args "install Package-postun-fail"
  Then the exit code is 0
   And Transaction is following
       | Action        | Package                            |
       | install       | Package-postun-fail-0:1.0-1.x86_64 |
  When I execute dnf with args "remove Package-postun-fail"
  Then the exit code is 0
   And stderr contains "Error in POSTUN scriptlet in rpm package Package-postun-fail"
   And Transaction is following
       | Action        | Package                           |
       | remove        | Package-postun-fail-0:1.0-1.x86_64 |
